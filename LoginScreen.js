import React, { useState } from 'react';
import { databases } from './appwriteConfig';

const LoginScreen = ({ onLogin }) => {
  const [name, setName] = useState('');
  const [agency, setAgency] = useState('');

  const handleRegister = async () => {
    if (name && agency) {
      // Save profile to Appwrite for accountability
      await databases.createDocument('tacnet_db', 'users', 'unique()', {
        name: name,
        agency: agency,
        status: 'active'
      });
      onLogin(); // Proceed to map
    } else {
      alert("Name and Agency are mandatory for mission accountability.");
    }
  };

  return (
    <div className="login-screen">
      <h2>MISSION SIGN-IN</h2>
      <input type="text" placeholder="Full Name" onChange={(e) => setName(e.target.value)} />
      <input type="text" placeholder="Agency" onChange={(e) => setAgency(e.target.value)} />
      <button onClick={handleRegister}>JOIN OPERATION</button>
    </div>
  );
};

export default LoginScreen;
