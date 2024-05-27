import React, { useEffect, useState, useRef } from 'react';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import './App.css';

const MatrixEffect = () => {
  const canvasRef = useRef(null);
  const [width, setWidth] = useState(window.innerWidth);
  const [height, setHeight] = useState(window.innerHeight);

  useEffect(() => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    canvas.width = width;
    canvas.height = height;

    const columns = Math.floor(canvas.width / 20);
    const ypos = Array(columns).fill(0);

    const matrix = () => {
      ctx.fillStyle = '#0001';
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      ctx.fillStyle = '#0f0';
      ctx.font = '15pt monospace';

      ypos.forEach((y, ind) => {
        const text = String.fromCharCode(65 + Math.random() * 58);

        const x = ind * 20;
        ctx.fillText(text, x, y);

        if (y > 100 + Math.random() * 10000) ypos[ind] = 0;
        else ypos[ind] = y + 20;
      });
    };

    const intervalId = setInterval(matrix, 50);

    return () => clearInterval(intervalId);
  }, [width, height]);

  useEffect(() => {
    const handleResize = () => {
      setWidth(window.innerWidth);
      setHeight(window.innerHeight);
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return <canvas ref={canvasRef} className="matrix-canvas"></canvas>;
};

function App() {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [intervalSec, setIntervalSec] = useState(1);

  useEffect(() => {
    const fetchData = () => {
      const backendUrl = process.env.REACT_APP_BACKEND_URL;
      fetch(`${backendUrl}/data`)
        .then((response) => {
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
          return response.json();
        })
        .then((data) => setData(data))
        .catch((error) => setError(error.message));
    };

    fetchData();
    const intervalId = setInterval(fetchData, intervalSec * 1000);
    return () => clearInterval(intervalId);
  }, [intervalSec]);

  const handleIntervalChange = (event) => {
    const newInterval = Number(event.target.value);
    if (newInterval > 0) {
      setIntervalSec(newInterval);
    }
  };

  return (
    <BrowserRouter basename="/Labcom-task">
      <div className="App">
        <Routes>
          <Route path="/" element={
            <>
              <MatrixEffect />
              <header className="App-header">
                {error ? (
                  <p>Error: {error}</p>
                ) : data ? (
                  <div>
                    <h1>
                      Hello Labcom
                      <input
                        type="number"
                        value={intervalSec}
                        onChange={handleIntervalChange}
                        className="input-interval"
                        min="1"
                      />
                    </h1>
                    <p>Selected query:</p>
                    <p>ID: {data.id}</p>
                    <p>Value: {data.value}</p>
                    <p>Description: {data.description}</p>
                  </div>
                ) : (
                  <p>Loading...</p>
                )}
              </header>
            </>
          } />
        </Routes>
      </div>
    </BrowserRouter>
  );
}

export default App;
