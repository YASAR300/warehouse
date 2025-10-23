import RNFS from 'react-native-fs';
import { Container } from '../types/Container';
import storage from '@react-native-firebase/storage';
import { PDFDocument, PDFPage, rgb } from 'react-native-pdf-lib';

export class StorageService {
  private tempDir = RNFS.TemporaryDirectoryPath;
  private documentsDir = RNFS.DocumentDirectoryPath;

  /**
   * Generate PDF report for a container
   */
  async generatePDF(container: Container): Promise<string> {
    try {
      const fileName = `${container.containerNumber}_report_${Date.now()}.pdf`;
      const pdfPath = `${this.documentsDir}/${fileName}`;

      // Create PDF document
      const page1 = PDFPage
        .create()
        .setMediaBox(200, 200)
        .drawText('Warehouse Container Report', {
          x: 20,
          y: 180,
          color: rgb(0, 0.2, 0.8),
          fontSize: 20,
        })
        .drawText(`Container #: ${container.containerNumber}`, {
          x: 20,
          y: 160,
          fontSize: 14,
        })
        .drawText(`Type: ${container.type}`, {
          x: 20,
          y: 145,
          fontSize: 12,
        })
        .drawText(`Door #: ${container.doorNumber || 'N/A'}`, {
          x: 20,
          y: 130,
          fontSize: 12,
        })
        .drawText(`Date: ${new Date().toLocaleDateString()}`, {
          x: 20,
          y: 115,
          fontSize: 12,
        })
        .drawText('Piece Count:', {
          x: 20,
          y: 95,
          fontSize: 14,
        });

      let yPos = 80;
      container.pieceCounts.forEach(pc => {
        page1.drawText(`  • ${pc.quantity} ${pc.packageType}`, {
          x: 20,
          y: yPos,
          fontSize: 10,
        });
        yPos -= 12;
      });

      yPos -= 10;
      page1.drawText('Materials Supplied:', {
        x: 20,
        y: yPos,
        fontSize: 14,
      });
      yPos -= 15;

      container.materialsSupplied.forEach(material => {
        page1.drawText(`  • ${material}`, {
          x: 20,
          y: yPos,
          fontSize: 10,
        });
        yPos -= 12;
      });

      if (container.discrepancies.length > 0) {
        yPos -= 10;
        page1.drawText('Discrepancies:', {
          x: 20,
          y: yPos,
          fontSize: 14,
          color: rgb(0.8, 0, 0),
        });
        yPos -= 15;

        container.discrepancies.forEach(disc => {
          page1.drawText(`  • ${disc.description}`, {
            x: 20,
            y: yPos,
            fontSize: 10,
          });
          yPos -= 12;
        });
      }

      const pdf = PDFDocument.create(pdfPath).addPages(page1);
      await pdf.write();

      return pdfPath;
    } catch (error) {
      console.error('Error generating PDF:', error);
      throw error;
    }
  }

  /**
   * Upload PDF to Firebase Storage and get shareable link
   */
  async uploadPDF(pdfPath: string, containerNumber: string): Promise<string> {
    try {
      const fileName = `${containerNumber}_${Date.now()}.pdf`;
      const reference = storage().ref(`reports/${fileName}`);

      await reference.putFile(pdfPath);
      const downloadUrl = await reference.getDownloadURL();

      return downloadUrl;
    } catch (error) {
      console.error('Error uploading PDF:', error);
      throw error;
    }
  }

  /**
   * Upload photo to Firebase Storage
   */
  async uploadPhoto(photoPath: string, containerNumber: string): Promise<string> {
    try {
      const fileName = `photo_${Date.now()}.jpg`;
      const reference = storage().ref(`containers/${containerNumber}/photos/${fileName}`);

      await reference.putFile(photoPath);
      const downloadUrl = await reference.getDownloadURL();

      return downloadUrl;
    } catch (error) {
      console.error('Error uploading photo:', error);
      throw error;
    }
  }

  /**
   * Upload multiple photos
   */
  async uploadPhotos(photoPaths: string[], containerNumber: string): Promise<string[]> {
    try {
      const uploadPromises = photoPaths.map(path => 
        this.uploadPhoto(path, containerNumber)
      );
      return await Promise.all(uploadPromises);
    } catch (error) {
      console.error('Error uploading photos:', error);
      throw error;
    }
  }

  /**
   * Delete photo from local storage
   */
  async deletePhoto(photoPath: string): Promise<void> {
    try {
      const exists = await RNFS.exists(photoPath);
      if (exists) {
        await RNFS.unlink(photoPath);
      }
    } catch (error) {
      console.error('Error deleting photo:', error);
      throw error;
    }
  }

  /**
   * Copy photo to app's document directory
   */
  async copyPhotoToDocuments(sourcePath: string): Promise<string> {
    try {
      const fileName = `photo_${Date.now()}.jpg`;
      const destPath = `${this.documentsDir}/${fileName}`;
      await RNFS.copyFile(sourcePath, destPath);
      return destPath;
    } catch (error) {
      console.error('Error copying photo:', error);
      throw error;
    }
  }

  /**
   * Get file size
   */
  async getFileSize(filePath: string): Promise<number> {
    try {
      const stat = await RNFS.stat(filePath);
      return stat.size;
    } catch (error) {
      console.error('Error getting file size:', error);
      return 0;
    }
  }

  /**
   * Clean up temporary files
   */
  async cleanupTempFiles(): Promise<void> {
    try {
      const files = await RNFS.readDir(this.tempDir);
      const deletePromises = files.map(file => RNFS.unlink(file.path));
      await Promise.all(deletePromises);
    } catch (error) {
      console.error('Error cleaning up temp files:', error);
    }
  }
}
