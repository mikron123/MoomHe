import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import { LocalizationProvider } from './localization.jsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <LocalizationProvider>
      <App />
    </LocalizationProvider>
  </React.StrictMode>,
)
