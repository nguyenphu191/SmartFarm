// src/services/alert.service.ts
import AlertSettings from '../models/alertSetting.model';
import Notification from '../models/notification.model';
import mongoose from 'mongoose';
import { sendEmailNotification } from './notification.service';
import User from '../models/user.model';
import Location from '../models/location.model';
import Season from '../models/season.model';

export async function checkAlertThresholds(
  locationId: string,
  sensorType: string,
  value: number,
  sensorDataId: mongoose.Types.ObjectId | string
) {
  try {
    // Tìm cài đặt cảnh báo cho vị trí
    const alertSettings = await AlertSettings.findOne({ locationId });
    
    if (!alertSettings) {
      console.log(`Không tìm thấy cài đặt cảnh báo cho vị trí ${locationId}`);
      return;
    }
    
    let isAlert = false;
    let alertMessage = '';
    
    // Kiểm tra dựa trên loại cảm biến
    switch (sensorType) {
      case 'temperature':
        if (value < alertSettings.temperature_min) {
          isAlert = true;
          alertMessage = `Nhiệt độ quá thấp: ${value}°C (ngưỡng: ${alertSettings.temperature_min}°C)`;
        } else if (value > alertSettings.temperature_max) {
          isAlert = true;
          alertMessage = `Nhiệt độ quá cao: ${value}°C (ngưỡng: ${alertSettings.temperature_max}°C)`;
        }
        break;
      
      case 'soil_moisture':
        if (value < alertSettings.soil_moisture_min) {
          isAlert = true;
          alertMessage = `Độ ẩm đất quá thấp: ${value}% (ngưỡng: ${alertSettings.soil_moisture_min}%)`;
        } else if (value > alertSettings.soil_moisture_max) {
          isAlert = true;
          alertMessage = `Độ ẩm đất quá cao: ${value}% (ngưỡng: ${alertSettings.soil_moisture_max}%)`;
        }
        break;
      
      case 'light_intensity':
        if (value < alertSettings.light_intensity_min) {
          isAlert = true;
          alertMessage = `Cường độ ánh sáng quá thấp: ${value} lux (ngưỡng: ${alertSettings.light_intensity_min} lux)`;
        } else if (value > alertSettings.light_intensity_max) {
          isAlert = true;
          alertMessage = `Cường độ ánh sáng quá cao: ${value} lux (ngưỡng: ${alertSettings.light_intensity_max} lux)`;
        }
        break;
    }
    
    // Tạo thông báo nếu vượt ngưỡng
    if (isAlert) {
      const notification = new Notification({
        type: `${sensorType}_alert`,
        message: alertMessage,
        locationId,
        sensorDataId,
        read: false,
        created_at: new Date()
      });
      
      await notification.save();
      console.log(`Đã tạo cảnh báo: ${alertMessage}`);
      
      // Gửi thông báo (push notification, email)
      await sendAlert(alertMessage, locationId);
    }
  } catch (error) {
    console.error('Lỗi khi kiểm tra ngưỡng cảnh báo:', error);
  }
}

async function sendAlert(message: string, locationId: string) {
  try {
    // Tìm location để lấy thông tin season
    const location = await Location.findById(locationId);
    if (!location) {
      console.error(`Không tìm thấy vị trí ${locationId}`);
      return;
    }
    
    // Tìm season để lấy thông tin user
    const season = await Season.findById(location.seasonId);
    if (!season) {
      console.error(`Không tìm thấy mùa vụ của vị trí ${locationId}`);
      return;
    }
    
    // Tìm user để lấy email
    const user = await User.findById(season.userId);
    if (!user) {
      console.error(`Không tìm thấy người dùng của mùa vụ ${season._id}`);
      return;
    }
    
    // Gửi email thông báo
    const subject = `Cảnh báo từ vị trí: ${location.name}`;
    await sendEmailNotification(user.email, subject, message);
    
    console.log(`Đã gửi cảnh báo "${message}" cho vị trí ${locationId} đến ${user.email}`);
  } catch (error) {
    console.error('Lỗi khi gửi cảnh báo:', error);
  }
}

/**
 * Lấy các thông báo chưa đọc
 */
export async function getUnreadNotifications(userId: string) {
  try {
    // Tìm tất cả thông báo chưa đọc, có thể thêm logic phân quyền nếu cần
    const notifications = await Notification.find({ read: false })
                                           .sort({ created_at: -1 })
                                           .limit(50); // Giới hạn số lượng
    return notifications;
  } catch (error) {
    console.error('Lỗi khi lấy thông báo chưa đọc:', error);
    throw error;
  }
}

// thông báo đã đọc
export async function markNotificationAsRead(notificationId: string) {
  try {
    const notification = await Notification.findByIdAndUpdate(
      notificationId,
      {
        read: true,
        read_at: new Date()
      },
      { new: true }
    );
    
    return notification;
  } catch (error) {
    console.error('Lỗi khi đánh dấu thông báo đã đọc:', error);
    throw error;
  }
}