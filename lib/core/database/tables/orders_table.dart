import 'package:drift/drift.dart';

// Define the table for storing Order Summary information
// We use 'Orders' as the table name, drift will generate 'OrderCache' as the data class name.
@DataClassName('OrderCache') 
class Orders extends Table {
  // Use the ID from the API as the primary key
  IntColumn get id => integer()(); 

  // Order Info
  TextColumn get orderSn => text().nullable()();
  TextColumn get state => text().nullable()(); // Make state nullable in the table

  // Simplified item info for list display
  TextColumn get firstItemName => text().nullable()();
  TextColumn get firstItemImage => text().nullable()();

  // Price and Time
  TextColumn get totalPrice => text().nullable()(); // Store formatted price string or use RealColumn for double
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id}; // Declare id as the primary key
} 