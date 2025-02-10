// Cubit to manage selection of Albums or Artists
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchTypeCubit extends Cubit<String> {
  SearchTypeCubit() : super('album');

  void selectAlbum() => emit('album');

  void selectArtist() => emit('artist');
}
