import React, { useState } from 'react';
import TacticalMapView from './TacticalMapView';
import LoginScreen from './LoginScreen';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  return (
    <div className="App">
      {!isAuthenticated ? (
        <LoginScreen onLogin={() => setIsAuthenticated(true)} />
      ) : (
        <TacticalMapView />
      )}
    </div>
  );
}

export default App;
