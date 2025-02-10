import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_emoodie/bloc/search_bloc.dart';
import 'package:spotify_emoodie/bloc/search_events.dart';
import 'package:spotify_emoodie/bloc/search_state.dart';
import 'package:spotify_emoodie/cubit/search_type_cubit.dart';

class SearchScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
          'Search',
          style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 25),
        )),
        body: StreamBuilder<ConnectivityResult>(
            stream: Connectivity()
                .onConnectivityChanged
                .map((results) => results.first),
            builder: (context, snapshot) {
              bool isConnected = snapshot.hasData &&
                  (snapshot.data == ConnectivityResult.mobile ||
                      snapshot.data == ConnectivityResult.wifi);
              return Column(children: [
                if (!isConnected)
                  Container(
                    width: double.infinity,
                    color: Colors.red,
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'No Internet Connection',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.9,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: TextField(
                                enabled: isConnected,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                ),
                                controller: _controller,
                                textAlign: TextAlign.start,
                                decoration: const InputDecoration(
                                  prefixIcon: Padding(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 5),
                                    // Adjust spacing
                                    child:
                                        Icon(Icons.search, color: Colors.black),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  hintText: 'Artists or Albums..',
                                  hintStyle: TextStyle(color: Colors.black),
                                  border: InputBorder.none,
                                ),
                                onChanged: (query) => {
                                      if (isConnected)
                                        _onSearchChanged(context, query),
                                    }),
                          )),
                      const SizedBox(height: 12),
                      BlocBuilder<SearchTypeCubit, String>(
                        builder: (context, selectedType) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color: selectedType == 'album'
                                          ? const Color(
                                              0xFF1DB954) // Spotify Green when selected
                                          : Colors.grey,
                                      width: 1.5, // Slightly thinner border
                                    ),
                                  ),
                                  backgroundColor: selectedType == 'album'
                                      ? const Color(
                                          0xFF1DB954) // Green when selected
                                      : Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  // Smaller button size
                                  minimumSize: const Size(
                                      60, 30), // Controls compact button size
                                ),
                                onPressed: isConnected
                                    ? () {
                                        context
                                            .read<SearchTypeCubit>()
                                            .selectAlbum();
                                        context.read<SearchBloc>().add(
                                            FetchSearchResults(
                                                _controller.text, 'album'));
                                      }
                                    : null,
                                child: const Text(
                                  'Albums',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
                                    // Smaller font like in the screenshot
                                    fontWeight: FontWeight
                                        .w500, // Slightly bold but not too thick
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Slightly reduced spacing between buttons
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color: selectedType == 'artist'
                                          ? const Color(0xFF1DB954)
                                          : Colors.grey,
                                      width: 1.5,
                                    ),
                                  ),
                                  backgroundColor: selectedType == 'artist'
                                      ? const Color(0xFF1DB954)
                                      : Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  // Matching the compact look
                                  minimumSize: const Size(60, 30),
                                ),
                                onPressed: isConnected
                                    ? () {
                                        context
                                            .read<SearchTypeCubit>()
                                            .selectArtist();
                                        context.read<SearchBloc>().add(
                                            FetchSearchResults(
                                                _controller.text, 'artist'));
                                      }
                                    : null,
                                child: const Text(
                                  'Artists',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      if (!isConnected) {
                        return const Center(
                          child: Text('Please check your internet connection'),
                        );
                      }
                      if (state is SearchLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is SearchLoaded) {
                        final selectedType =
                            context.read<SearchTypeCubit>().state;
                        if (selectedType == 'album') {
                          // Albums in a Grid
                          final mediaQuery = MediaQuery.of(context);
                          final isPortrait =
                              mediaQuery.orientation == Orientation.portrait;
                          int columns =
                              (mediaQuery.size.width / (isPortrait ? 160 : 200))
                                  .floor();
                          columns =
                              columns < 2 ? 2 : (columns > 4 ? 4 : columns);
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: isPortrait ? 0.78 : 1.2),
                            itemCount: state.results.length,
                            itemBuilder: (context, index) {
                              final item = state.results[index];
                              return SizedBox(
                                  height: isPortrait ? 200 : 160,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      item['images'] != null &&
                                              item['images'].isNotEmpty
                                          ? Image.network(
                                              item['images'][0]['url'],
                                              height: isPortrait ? 140 : 90,
                                              width: double.infinity,
                                              fit: BoxFit.fill)
                                          : const Icon(Icons.music_note,
                                              size: 50),
                                      Flexible(
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['name'],
                                                  // Album or artist name
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: 'Roboto',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (item['artists'] != null &&
                                                    item['artists'].isNotEmpty)
                                                  Text(
                                                    item['artists'][0]['name'],
                                                    // Artist name
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: 'Roboto',
                                                        color: Colors.grey),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                if (item['release_date'] !=
                                                    null)
                                                  Text(
                                                    '${item['album_type'] ?? 'Single'} • ${item['release_date'].split('-')[0]}',
                                                    // Album type & Year
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: 'Roboto',
                                                        color: Colors.grey),
                                                  ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ));
                            },
                          );
                        } else {
                          // Artists in a List
                          return ListView.builder(
                            itemCount: state.results.length,
                            itemBuilder: (context, index) {
                              final item = state.results[index];
                              return ListTile(
                                leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: item['images'] != null &&
                                            item['images'].isNotEmpty
                                        ? Image.network(
                                            item['images'][0]['url'],
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover)
                                        : Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              // Placeholder color
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      25), // Rounded shape
                                            ),
                                            child: Icon(Icons.person, size: 50),
                                          )),
                                title: Text(item['name'],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.bold)),
                              );
                            },
                          );
                        }
                      } else if (state is SearchError) {
                        return Center(child: Text(state.errorMessage));
                      }
                      return const Center(
                          child: Text('Search for albums or artists'));
                    },
                  ),
                ),
              ]);
            }));
  }

  void _onSearchChanged(BuildContext context, String query) {
    query = query.trim(); // Trim whitespace to prevent redundant searches
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        final selectedType = context.read<SearchTypeCubit>().state;
        context.read<SearchBloc>().add(FetchSearchResults(query, selectedType));
      }
    });
  }
}
