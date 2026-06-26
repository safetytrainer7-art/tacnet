import { databases } from './appwriteConfig';

export const terminateSearch = async (commanderId, operationId) => {
  try {
    // 1. Verify Commander authority
    const commander = await databases.getDocument('tacnet_db', 'users', commanderId);
    
    if (commander.role === 'commander') {
      // 2. Update operation status to 'terminated'
      await databases.updateDocument('tacnet_db', 'operations', operationId, {
        status: 'terminated',
        terminatedAt: new Date().toISOString()
      });
      console.log("Operation successfully terminated by Commander:", commander.name);
    } else {
      console.error("Unauthorized: Only a Commander can terminate a search.");
    }
  } catch (error) {
    console.error("Termination request failed:", error);
  }
};
