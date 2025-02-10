abstract class SearchEvent {}

class FetchSearchResults extends SearchEvent {
  final String query;
  final String type;

  FetchSearchResults(this.query, this.type);
}
