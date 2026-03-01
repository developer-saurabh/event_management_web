class EventModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final double price;
  final String organizerId;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.price,
    required this.organizerId,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'],
      description: map['description'],
      date: map['date'],
      price: map['price'],
      organizerId: map['organizerId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'price': price,
      'organizerId': organizerId,
    };
  }
}