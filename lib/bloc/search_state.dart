abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<dynamic> results;
  final String type;

  SearchLoaded(this.results, this.type);
}

class SearchError extends SearchState {
  final String errorMessage;

  SearchError(this.errorMessage);
}
