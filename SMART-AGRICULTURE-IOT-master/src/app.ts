import bodyParser from "body-parser";
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";
import predictService from "./services/image_predict";
import fileUploadRouter from "./handler/file_upload";
import predictRouter from "./handler/predict";
import authRouter from "./routes/auth.routes"; 
import seasonRouter from "./routes/season.routes";
import locationRouter from "./routes/location.routes";
import plantRouter from "./routes/plant.routes"; 
import connectDB from "./config/database";
import sensorRouter from "./routes/sensor.routes"; 
import alertRouter from "./routes/alert.routes";
import notificationRouter from "./routes/notification.routes";
import carePlanRouter from "./routes/carePlan.routes"; 
import seasonHistoryRouter from "./routes/seasonHistory.routes"; 
import deviceRouter from './routes/device.routes';



import './services/mqtt.service'; 

// Load environment variables
dotenv.config();  

// Initialize express app
export const app = express();
const port = process.env.PORT ? parseInt(process.env.PORT) : 3000;

// Connect to MongoDB Atlas
connectDB()
  .then(() => console.log("MongoDB Atlas connected successfully"))
  .catch((err) => {
    console.error("MongoDB connection error:", err);
    process.exit(1);
  });

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static("public"));
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

// Routes
app.use("/", fileUploadRouter);
app.use("/", predictRouter);
app.use("/auth", authRouter);
app.use("/api/seasons", seasonRouter);
app.use("/api/seasons/:seasonId/locations", locationRouter);
app.use("/api/seasons/:seasonId/locations/:locationId/plants", plantRouter); // Nested route for plants
// Thêm routes
app.use('/api/sensors', sensorRouter);
app.use('/api/alerts', alertRouter);
app.use('/api/notifications', notificationRouter);
app.use('/api/seasons/:seasonId/locations/:locationId/plants/:plantId/care-plan', carePlanRouter);
app.use('/api/season-histories', seasonHistoryRouter);
app.use('/api/devices', deviceRouter);



// Root endpoint
app.get("/", (req, res) => {
  res.json({ message: "Smart Agriculture IoT API is running" });
});

// Initialize prediction model
const initModel = async () => {
  try {
    await predictService.loadModel();
    console.log("Prediction model loaded successfully");
  } catch (error) {
    console.error("Error initializing model:", error);
  }
};

// Start server
app.listen(port, () => {
  console.log(`Server started at http://localhost:${port}`);
  // Initialize model after server starts
  initModel();
});
