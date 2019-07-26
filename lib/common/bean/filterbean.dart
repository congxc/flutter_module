import 'destination.dart';
import 'people.dart';

class FilterBean{
  DateTime startTime;
  DateTime endTime;
  Destination destination;
  People people;

  FilterBean(this.startTime, this.endTime, this.destination, this.people);

  @override
  String toString() {
    return 'FilterBean{startTime: $startTime, endTime: $endTime, destination: $destination, people: $people}';
  }


}