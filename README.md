# Moomhe - Professional Design Platform

A modern SaaS webapp for professional design work across multiple categories including Interior/Exterior design, Gardening, Cars, Tattoos, Carpentry, and Products.

## Features

- **Category Selection**: Horizontal gallery of professional design areas
- **Image Upload**: Drag-and-drop or click-to-upload functionality for user images
- **Design Tools**: Interactive buttons for adding objects, changing wall colors, adjusting angles, and more
- **Modern UI**: Beautiful, responsive design with Tailwind CSS
- **Real-time Preview**: Live preview of design changes

## Getting Started

### Prerequisites

- Node.js (version 16 or higher)
- npm or yarn

### Installation

1. Clone the repository or navigate to the project directory
2. Install dependencies:
   ```bash
   npm install
   ```

### Running the Application

1. Start the development server:
   ```bash
   npm run dev
   ```

2. Open your browser and navigate to `http://localhost:3000`

### Building for Production

```bash
npm run build
```

## Usage

1. **Select a Category**: Click on any category in the horizontal gallery (Interior/Exterior design is selected by default)
2. **Upload Your Image**: Click on the upload area in the sidebar to select and upload your room image
3. **Use Design Tools**: Click on the various buttons below the main image to apply design changes:
   - Add Object
   - Change Wall Color
   - Angle
   - Lighting
   - Add Furniture
   - Textures

## Technology Stack

- **React 18**: Modern React with hooks
- **Vite**: Fast build tool and development server
- **Tailwind CSS**: Utility-first CSS framework
- **Lucide React**: Beautiful icon library

## Project Structure

```
moomhe/
├── public/
├── src/
│   ├── App.jsx          # Main application component
│   ├── main.jsx         # React entry point
│   └── index.css        # Global styles and Tailwind imports
├── package.json
├── vite.config.js
├── tailwind.config.js
└── README.md
```

## Customization

The application is built with modularity in mind. You can easily:

- Add new categories to the gallery
- Modify the design tools and their functionality
- Customize the color scheme in `tailwind.config.js`
- Add new features and components

## License

This project is open source and available under the MIT License.
