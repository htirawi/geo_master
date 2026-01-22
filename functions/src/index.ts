import * as functions from "firebase-functions/v1";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

initializeApp();

const db = getFirestore();

/**
 * Triggered when a new user is created
 * Creates the initial user document with default values
 */
export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  const { uid, email, displayName, photoURL } = user;

  const userDoc = {
    id: uid,
    email: email || null,
    displayName: displayName || null,
    photoUrl: photoURL || null,
    isAnonymous: !email,
    isEmailVerified: user.emailVerified || false,
    isPremium: false,
    createdAt: FieldValue.serverTimestamp(),
    lastLoginAt: FieldValue.serverTimestamp(),
    preferences: {
      language: "en",
      isDarkMode: false,
      soundEnabled: true,
      hapticsEnabled: true,
      notificationsEnabled: true,
      dailyReminderEnabled: true,
      dailyGoalMinutes: 15,
      difficultyLevel: "medium",
      interests: [],
    },
    progress: {
      totalXp: 0,
      level: 1,
      currentStreak: 0,
      longestStreak: 0,
      lastActiveDate: null,
      countriesLearned: 0,
      quizzesCompleted: 0,
      questionsAnswered: 0,
      correctAnswers: 0,
      unlockedAchievements: [],
      regionProgress: {},
    },
  };

  try {
    await db.collection("users").doc(uid).set(userDoc, { merge: true });
    functions.logger.info(`Created user document for ${uid}`);
  } catch (error) {
    functions.logger.error(`Error creating user document for ${uid}:`, error);
  }
});

/**
 * Triggered when a user is deleted
 * Cleans up user data
 */
export const onUserDeleted = functions.auth.user().onDelete(async (user) => {
  const { uid } = user;

  try {
    // Delete user document
    await db.collection("users").doc(uid).delete();

    // Delete user's subcollections
    const batch = db.batch();

    // Delete learned countries
    const learnedCountries = await db
      .collection("users")
      .doc(uid)
      .collection("learned_countries")
      .get();
    learnedCountries.docs.forEach((doc) => batch.delete(doc.ref));

    // Delete quiz history
    const quizHistory = await db
      .collection("users")
      .doc(uid)
      .collection("quiz_history")
      .get();
    quizHistory.docs.forEach((doc) => batch.delete(doc.ref));

    await batch.commit();
    functions.logger.info(`Deleted all data for user ${uid}`);
  } catch (error) {
    functions.logger.error(`Error deleting user data for ${uid}:`, error);
  }
});

/**
 * Scheduled function to reset daily streaks
 * Runs every day at midnight UTC
 */
export const resetDailyStreaks = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("UTC")
  .onRun(async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 2);

    try {
      // Find users who haven't been active in 2+ days
      const inactiveUsers = await db
        .collection("users")
        .where("progress.lastActiveDate", "<", yesterday)
        .where("progress.currentStreak", ">", 0)
        .get();

      const batch = db.batch();
      let count = 0;

      inactiveUsers.docs.forEach((doc) => {
        batch.update(doc.ref, {
          "progress.currentStreak": 0,
        });
        count++;
      });

      if (count > 0) {
        await batch.commit();
        functions.logger.info(`Reset streaks for ${count} inactive users`);
      }
    } catch (error) {
      functions.logger.error("Error resetting daily streaks:", error);
    }
  });

/**
 * Update leaderboard rankings
 * Runs every hour
 */
export const updateLeaderboard = functions.pubsub
  .schedule("0 * * * *")
  .timeZone("UTC")
  .onRun(async () => {
    try {
      // Get top 100 users by XP
      const topUsers = await db
        .collection("users")
        .orderBy("progress.totalXp", "desc")
        .limit(100)
        .get();

      const leaderboardData = topUsers.docs.map((doc, index) => {
        const data = doc.data();
        return {
          rank: index + 1,
          userId: doc.id,
          displayName: data.displayName || "Anonymous",
          photoUrl: data.photoUrl || null,
          totalXp: data.progress?.totalXp || 0,
          level: data.progress?.level || 1,
          countriesLearned: data.progress?.countriesLearned || 0,
          updatedAt: FieldValue.serverTimestamp(),
        };
      });

      // Store leaderboard snapshot
      await db.collection("leaderboards").doc("global").set({
        entries: leaderboardData,
        updatedAt: FieldValue.serverTimestamp(),
      });

      functions.logger.info(`Updated leaderboard with ${leaderboardData.length} entries`);
    } catch (error) {
      functions.logger.error("Error updating leaderboard:", error);
    }
  });

/**
 * Send daily reminder notifications
 * Runs every day at 9 AM UTC
 */
export const sendDailyReminders = functions.pubsub
  .schedule("0 9 * * *")
  .timeZone("UTC")
  .onRun(async () => {
    try {
      // Find users with daily reminders enabled who haven't played today
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const usersToNotify = await db
        .collection("users")
        .where("preferences.dailyReminderEnabled", "==", true)
        .where("preferences.notificationsEnabled", "==", true)
        .get();

      let notificationCount = 0;

      for (const doc of usersToNotify.docs) {
        const data = doc.data();
        const lastActive = data.progress?.lastActiveDate?.toDate();

        // Skip if user was active today
        if (lastActive && lastActive >= today) {
          continue;
        }

        // Get user's FCM token (would need to be stored separately)
        const tokenDoc = await db.collection("fcm_tokens").doc(doc.id).get();
        if (!tokenDoc.exists) continue;

        const token = tokenDoc.data()?.token;
        if (!token) continue;

        const streak = data.progress?.currentStreak || 0;
        const message = streak > 0 ?
          `Don't break your ${streak}-day streak! Take a quick geography quiz today.` :
          "Ready to explore the world? Start your geography journey today!";

        try {
          await getMessaging().send({
            token,
            notification: {
              title: "GeoMaster Daily Reminder",
              body: message,
            },
            data: {
              type: "daily_reminder",
              streak: streak.toString(),
            },
          });
          notificationCount++;
        } catch (sendError) {
          // Token might be invalid, log but continue
          functions.logger.warn(`Failed to send notification to ${doc.id}:`, sendError);
        }
      }

      functions.logger.info(`Sent ${notificationCount} daily reminder notifications`);
    } catch (error) {
      functions.logger.error("Error sending daily reminders:", error);
    }
  });

/**
 * Achievement checker - triggered when user progress is updated
 */
export const checkAchievements = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const userId = context.params.userId;

    const beforeProgress = before.progress || {};
    const afterProgress = after.progress || {};

    const newAchievements: string[] = [];
    const existingAchievements = afterProgress.unlockedAchievements || [];

    // Check for new achievements
    const achievementChecks = [
      {
        id: "first_quiz",
        condition: afterProgress.quizzesCompleted >= 1 && beforeProgress.quizzesCompleted < 1,
      },
      {
        id: "quiz_master_10",
        condition: afterProgress.quizzesCompleted >= 10 && beforeProgress.quizzesCompleted < 10,
      },
      {
        id: "quiz_master_50",
        condition: afterProgress.quizzesCompleted >= 50 && beforeProgress.quizzesCompleted < 50,
      },
      {
        id: "quiz_master_100",
        condition: afterProgress.quizzesCompleted >= 100 && beforeProgress.quizzesCompleted < 100,
      },
      {
        id: "explorer_10",
        condition: afterProgress.countriesLearned >= 10 && beforeProgress.countriesLearned < 10,
      },
      {
        id: "explorer_50",
        condition: afterProgress.countriesLearned >= 50 && beforeProgress.countriesLearned < 50,
      },
      {
        id: "explorer_100",
        condition: afterProgress.countriesLearned >= 100 && beforeProgress.countriesLearned < 100,
      },
      {
        id: "streak_7",
        condition: afterProgress.currentStreak >= 7 && beforeProgress.currentStreak < 7,
      },
      {
        id: "streak_30",
        condition: afterProgress.currentStreak >= 30 && beforeProgress.currentStreak < 30,
      },
      {
        id: "streak_100",
        condition: afterProgress.currentStreak >= 100 && beforeProgress.currentStreak < 100,
      },
      {
        id: "level_5",
        condition: afterProgress.level >= 5 && beforeProgress.level < 5,
      },
      {
        id: "level_10",
        condition: afterProgress.level >= 10 && beforeProgress.level < 10,
      },
      {
        id: "level_25",
        condition: afterProgress.level >= 25 && beforeProgress.level < 25,
      },
      {
        id: "level_50",
        condition: afterProgress.level >= 50 && beforeProgress.level < 50,
      },
    ];

    for (const check of achievementChecks) {
      if (check.condition && !existingAchievements.includes(check.id)) {
        newAchievements.push(check.id);
      }
    }

    if (newAchievements.length > 0) {
      try {
        await change.after.ref.update({
          "progress.unlockedAchievements": FieldValue.arrayUnion(...newAchievements),
        });
        functions.logger.info(
          `Unlocked ${newAchievements.length} achievements for user ${userId}:`,
          newAchievements
        );
      } catch (error) {
        functions.logger.error(`Error unlocking achievements for ${userId}:`, error);
      }
    }
  });
