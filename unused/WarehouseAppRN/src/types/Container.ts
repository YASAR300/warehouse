export enum ContainerType {
  IMPORT = 'Import',
  EXPORT = 'Export',
  DELIVERY = 'Delivery',
}

export enum PackageType {
  CRATES = 'Crates',
  PALLETS = 'Pallets',
  COILS = 'Coils',
  REELS = 'Reels',
  BUNDLES = 'Bundles',
  CARTONS = 'Cartons',
  CAR = 'Car',
  BIKE = 'Bike',
  BOAT = 'Boat',
  OTHER = 'Other',
}

export enum MaterialType {
  PALLETS = 'Pallets',
  SHRINK_WRAP = 'Shrink Wrap',
  AIR_BAGS = 'Air Bags',
  DUNNAGE = 'Dunnage',
}

export interface PieceCount {
  quantity: number;
  packageType: PackageType;
}

export interface Discrepancy {
  description: string;
  timestamp: Date;
  photoPaths?: string[];
}

export interface Container {
  id: string;
  containerNumber: string;
  type: ContainerType;
  pieceCounts: PieceCount[];
  materialsSupplied: MaterialType[];
  discrepancies: Discrepancy[];
  photoPaths: string[];
  doorNumber?: string;
  completedAt?: Date;
  shareableLink?: string;
  isCompleted: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface ContainerFormData {
  containerNumber: string;
  type: ContainerType;
  doorNumber: string;
}
