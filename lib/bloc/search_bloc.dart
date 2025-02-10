import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_emoodie/repository/spotify_repository.dart';
import 'package:spotify_emoodie/bloc/search_events.dart';
import 'package:spotify_emoodie/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SpotifyRepository apiService = SpotifyRepository();
  String _lastQuery = '';
  String _lastType = '';

  SearchBloc() : super(SearchInitial()) {
    on<FetchSearchResults>((event, emit) async {
      if (event.query == _lastQuery && event.type == _lastType) {
        return; // Prevent unnecessary API calls
      }
      _lastQuery = event.query;
      _lastType = event.type;

      emit(SearchLoading());
      try {
        final response = await apiService.search(event.query, event.type);
        emit(SearchLoaded(response.data['${event.type}s']['items'] ?? [], event.type));
      } catch (e) {
        if (kDebugMode) {
          debugPrint("Search API Error: $e");
        }  // Log error for debugging
        emit(SearchError("Failed to fetch results. Please try again later."));
        //if we show actual error
        //emit(SearchError("Error: ${e.toString()}"));
      }
    });
  }
}
