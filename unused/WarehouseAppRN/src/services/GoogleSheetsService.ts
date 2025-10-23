import axios from 'axios';
import { Container, ContainerType, PackageType, MaterialType } from '../types/Container';
import { GOOGLE_SHEETS_API_KEY, GOOGLE_SHEETS_SPREADSHEET_ID, ADMIN_EMAIL } from '@env';

export class GoogleSheetsService {
  private apiKey: string;
  private spreadsheetId: string;
  private baseUrl = 'https://sheets.googleapis.com/v4/spreadsheets';

  constructor() {
    this.apiKey = GOOGLE_SHEETS_API_KEY;
    this.spreadsheetId = GOOGLE_SHEETS_SPREADSHEET_ID;
  }

  /**
   * Get all containers from Google Sheets
   */
  async getContainers(): Promise<Container[]> {
    try {
      const range = 'Sheet1!A2:Z'; // Skip header row
      const url = `${this.baseUrl}/${this.spreadsheetId}/values/${range}?key=${this.apiKey}`;
      
      const response = await axios.get(url);
      const rows = response.data.values || [];

      return rows.map((row: any[]) => this.parseRowToContainer(row));
    } catch (error) {
      console.error('Error fetching containers from Google Sheets:', error);
      throw error;
    }
  }

  /**
   * Add a new container to Google Sheets
   */
  async addContainer(container: Container): Promise<void> {
    try {
      const range = 'Sheet1!A:Z';
      const url = `${this.baseUrl}/${this.spreadsheetId}/values/${range}:append?valueInputOption=RAW&key=${this.apiKey}`;
      
      const row = this.containerToRow(container);
      
      await axios.post(url, {
        values: [row],
      });
    } catch (error) {
      console.error('Error adding container to Google Sheets:', error);
      throw error;
    }
  }

  /**
   * Update container in Google Sheets
   */
  async updateContainer(container: Container): Promise<void> {
    try {
      // Find the row index for this container
      const rowIndex = await this.findContainerRow(container.containerNumber);
      
      if (rowIndex === -1) {
        // Container doesn't exist, add it
        await this.addContainer(container);
        return;
      }

      const range = `Sheet1!A${rowIndex}:Z${rowIndex}`;
      const url = `${this.baseUrl}/${this.spreadsheetId}/values/${range}?valueInputOption=RAW&key=${this.apiKey}`;
      
      const row = this.containerToRow(container);
      
      await axios.put(url, {
        values: [row],
      });

      // Update row formatting if completed
      if (container.isCompleted) {
        await this.updateRowFormatting(rowIndex, true);
      }
    } catch (error) {
      console.error('Error updating container in Google Sheets:', error);
      throw error;
    }
  }

  /**
   * Find the row index for a container number
   */
  private async findContainerRow(containerNumber: string): Promise<number> {
    try {
      const range = 'Sheet1!A:A';
      const url = `${this.baseUrl}/${this.spreadsheetId}/values/${range}?key=${this.apiKey}`;
      
      const response = await axios.get(url);
      const values = response.data.values || [];

      for (let i = 0; i < values.length; i++) {
        if (values[i][0] === containerNumber) {
          return i + 1; // Sheets are 1-indexed
        }
      }

      return -1;
    } catch (error) {
      console.error('Error finding container row:', error);
      return -1;
    }
  }

  /**
   * Update row formatting (background color for completed containers)
   */
  private async updateRowFormatting(rowIndex: number, isCompleted: boolean): Promise<void> {
    try {
      // Note: This requires OAuth2 authentication, not just API key
      // For production, implement proper OAuth2 flow
      // For now, this is a placeholder
      console.log(`Would update row ${rowIndex} formatting to completed: ${isCompleted}`);
    } catch (error) {
      console.error('Error updating row formatting:', error);
    }
  }

  /**
   * Send notification email for discrepancies
   */
  async sendDiscrepancyNotification(container: Container): Promise<void> {
    try {
      // This would typically use a backend service or Firebase Functions
      // For now, we'll log it
      console.log(`Discrepancy notification for container ${container.containerNumber}`);
      console.log(`Admin email: ${ADMIN_EMAIL}`);
      console.log(`Discrepancies:`, container.discrepancies);
      
      // In production, implement email sending via:
      // - Firebase Cloud Functions
      // - SendGrid API
      // - AWS SES
      // - Or your preferred email service
    } catch (error) {
      console.error('Error sending discrepancy notification:', error);
    }
  }

  /**
   * Parse a spreadsheet row into a Container object
   */
  private parseRowToContainer(row: any[]): Container {
    return {
      id: row[0] || '',
      containerNumber: row[0] || '',
      type: this.parseContainerType(row[1]),
      pieceCounts: this.parsePieceCounts(row[2]),
      materialsSupplied: this.parseMaterials(row[3]),
      doorNumber: row[4] || undefined,
      completedAt: row[5] ? new Date(row[5]) : undefined,
      shareableLink: row[6] || undefined,
      isCompleted: row[7]?.toLowerCase() === 'true',
      discrepancies: this.parseDiscrepancies(row[9]),
      photoPaths: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    };
  }

  /**
   * Convert a Container object to a spreadsheet row
   */
  private containerToRow(container: Container): any[] {
    return [
      container.containerNumber,
      container.type,
      this.formatPieceCounts(container.pieceCounts),
      this.formatMaterials(container.materialsSupplied),
      container.doorNumber || '',
      container.completedAt ? container.completedAt.toISOString() : '',
      container.shareableLink || '',
      container.isCompleted.toString(),
      container.discrepancies.length > 0 ? 'Yes' : 'No',
      this.formatDiscrepancies(container.discrepancies),
    ];
  }

  private parseContainerType(typeString: string): ContainerType {
    switch (typeString?.toLowerCase()) {
      case 'export':
        return ContainerType.EXPORT;
      case 'delivery':
        return ContainerType.DELIVERY;
      default:
        return ContainerType.IMPORT;
    }
  }

  private parsePieceCounts(pieceCountString: string): any[] {
    if (!pieceCountString) return [];
    // Parse format like "10 Pallets, 5 Crates"
    const parts = pieceCountString.split(',').map(p => p.trim());
    return parts.map(part => {
      const match = part.match(/(\d+)\s+(.+)/);
      if (match) {
        return {
          quantity: parseInt(match[1]),
          packageType: match[2] as PackageType,
        };
      }
      return null;
    }).filter(Boolean);
  }

  private parseMaterials(materialsString: string): MaterialType[] {
    if (!materialsString) return [];
    return materialsString.split(',').map(m => m.trim() as MaterialType);
  }

  private parseDiscrepancies(discrepanciesString: string): any[] {
    if (!discrepanciesString) return [];
    return discrepanciesString.split(';').map(d => ({
      description: d.trim(),
      timestamp: new Date(),
    }));
  }

  private formatPieceCounts(pieceCounts: any[]): string {
    return pieceCounts.map(pc => `${pc.quantity} ${pc.packageType}`).join(', ');
  }

  private formatMaterials(materials: MaterialType[]): string {
    return materials.join(', ');
  }

  private formatDiscrepancies(discrepancies: any[]): string {
    return discrepancies.map(d => d.description).join('; ');
  }
}
