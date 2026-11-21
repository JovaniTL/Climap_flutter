import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/weather/weather_bloc.dart';
import '../../blocs/weather/weather_event.dart';
import '../../blocs/weather/weather_state.dart';

class PlaceSearchBar extends StatefulWidget {
  const PlaceSearchBar({super.key});

  @override
  State<PlaceSearchBar> createState() => _PlaceSearchBarState();
}

class _PlaceSearchBarState extends State<PlaceSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    context.read<WeatherBloc>().add(SearchPlacesRequested(value));
    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    context.read<WeatherBloc>().add(const ClearSearchResultsRequested());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        final hasResults = state.searchResults.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(28),
              color: scheme.surface,
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                onSubmitted: (value) {
                  context.read<WeatherBloc>().add(SearchPlacesRequested(value));
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar ciudad o localidad...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: state.isSearchingPlaces
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : (_controller.text.isNotEmpty
                            ? IconButton(
                                tooltip: 'Limpiar búsqueda',
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.close_rounded),
                              )
                            : null),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            if (hasResults) ...[
              const SizedBox(height: 6),
              Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(20),
                color: scheme.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: state.searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final place = state.searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: place.subtitle.isNotEmpty
                            ? Text(
                                place.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        onTap: () {
                          _controller.text = place.name;
                          FocusScope.of(context).unfocus();
                          context.read<WeatherBloc>().add(
                            SearchPlaceSelected(place),
                          );
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
