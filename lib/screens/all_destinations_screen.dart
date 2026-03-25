// Écran listant toutes les destinations avec shimmer loader.
// Accessible depuis "Explorer toutes les destinations" sur la page d'accueil.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/destination.dart';
import '../navigation/app_page_route.dart';
import '../providers/destinations_provider.dart';
import '../providers/view_counter_provider.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/destination_card.dart';
import '../widgets/shimmer_card.dart';
import 'detail_screen.dart';

class AllDestinationsScreen extends ConsumerWidget {
  const AllDestinationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(destinationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Toutes les destinations',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: allAsync.when(
        loading: () => const ShimmerList(count: 8),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Erreur : $e',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
        data: (all) {
          if (all.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_off_rounded,
                      size: 64,
                      color: AppColors.gold.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune destination disponible',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A3C34), Color(0xFF2D6A4F)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Text(
                  '${all.length} destination${all.length > 1 ? 's' : ''} au Cameroun',
                  style: GoogleFonts.lato(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: all.length,
                  itemBuilder: (context, index) {
                    final dest = all[index];
                    final views =
                        ref.watch(viewCounterProvider)[dest.id] ?? 0;
                    return AnimatedListItem(
                      index: index,
                      key: ValueKey(dest.id),
                      child: DestinationCard(
                        destination: dest,
                        viewCount: views,
                        onTap: (Destination d) {
                          ref
                              .read(viewCounterProvider.notifier)
                              .increment(d.id);
                          Navigator.push(
                            context,
                            SlideRightRoute(page: DetailScreen(destination: d)),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
