import { databases, realtime } from './appwriteConfig';

export const triggerSOS = async (userId) => {
  try {
    // 1. Fetch the user's identity from the database
    const user = await databases.getDocument('tacnet_db', 'users', userId);
    
    // 2. Broadcast the SOS alert to all connected devices
    const alertData = {
      message: "EMERGENCY: OFFICER IN DISTRESS",
      name: user.name,
      agency: user.agency,
      timestamp: new Date().toISOString()
    };
    
    // Push alert to the real-time feed
    await databases.createDocument('tacnet_db', 'alerts', 'unique()', alertData);
    console.log("SOS Broadcasted for:", alertData.name);
    
  } catch (error) {
    console.error("SOS Alert failed to broadcast:", error);
  }
};
