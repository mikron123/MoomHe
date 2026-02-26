import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import { LocalizationProvider } from './localization.jsx'
import { aiService } from './aiService.js'
import './index.css'

// /app uses GPT-image-1.5 (experimental), /test uses Vertex AI (Gemini 3.1)
const isTestPage = window.location.pathname.startsWith('/test')
if (!isTestPage) {
  aiService.setUseExperimentalModel(true)
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <LocalizationProvider>
      <App />
    </LocalizationProvider>
  </React.StrictMode>,
)
