import { Client, Account, Databases, Realtime } from 'appwrite';

// Initialize the Appwrite Client
const client = new Client();

// Replace these placeholders with your actual Appwrite Project IDs
client
    .setEndpoint('https://nyc.cloud.appwrite.io/v1') // Your Appwrite API Endpoint
    .setProject('6a38e834003e0cc64c31');         // Your specific Project ID

export const account = new Account(client);
export const databases = new Databases(client);
export const realtime = new Realtime(client);

export default client;
