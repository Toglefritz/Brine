const admin = require('firebase-admin');

class NotificationService {
    /**
     * Sends a push notification to the given FCM tokens.
     * 
     * This service uses Firebase Cloud Messaging to send push notifications to users' devices. Assuming they have 
     * enabled notifications for the app on their device, this function can be used to send a push notification to a 
     * user by their FCM token(s). An FCM token is a unique identifier for a device that is used to send push 
     * notifications to that device. The mobile app is responsible for registering the device with FCM and obtaining the
     * token.
     * 
     * Summary:
     *  - Uses Firebase Cloud Messaging (FCM) to send push notifications.
     *  - Accepts multiple FCM tokens (since a user may have multiple devices registered).
     *  - Logs successes and failures.
     * 
     * @param {Array<string>} tokens - The FCM tokens of the user.
     * @param {string} title - The title of the notification.
     * @param {string} body - The message body of the notification.
     */
    static async sendNotification(tokens, title, body) {
        if (!tokens || tokens.length === 0) {
            console.warn('No FCM tokens available to send notifications.');
            return;
        }

        const message = {
            notification: { title, body },
            tokens: tokens, // Supports multiple devices per user
        };

        try {
            const response = await admin.messaging().sendEachForMulticast(message);
            console.log('Push notification sent successfully:', response);
        } catch (error) {
            console.error('Error sending push notification:', error);
        }
    }
}

module.exports = NotificationService;