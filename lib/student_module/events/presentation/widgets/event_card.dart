import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

import '../../models/event_item.dart';
import 'event_formatters.dart';

List<BoxShadow> eventCardShadow() => [
  BoxShadow(
    color: AppPalette.buttonShadowColor.withValues(alpha: 0.7),
    blurRadius: 14,
    offset: const Offset(0, 5),
  ),
];

/// Photo of the event, or a coloured icon tile when there is no image.
class EventImage extends StatelessWidget {
  const EventImage({super.key, required this.event, this.size = 108});

  final EventItem event;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tile = EventTiles.of(event.category);

    Widget fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tile.colors,
        ),
      ),
      child: Icon(tile.icon, color: AppPalette.white, size: size * 0.46),
    );

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: event.imageUrl.isEmpty
            ? fallback
            : Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback,
              ),
      ),
    );
  }
}

/// One event: picture, title, venue, dates, eligibility, description and the
/// Register button (Register Now / Registered / Registration Closed).
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.registered,
    required this.registering,
    required this.onRegister,
  });

  final EventItem event;
  final bool registered;
  final bool registering;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final open = event.isRegistrationOpen(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: eventCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventImage(event: event),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: AppPalette.authTextPrimaryColor,
                      ),
                    ),
                    if (event.venue.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 22,
                            color: AppPalette.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Venue',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppPalette.authTextSecondaryColor,
                                  ),
                                ),
                                Text(
                                  event.venue,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppPalette.authTextPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // dates
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppPalette.primaryBlue.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DateBlock(
                    icon: Icons.calendar_today_outlined,
                    label: 'Event Date',
                    value: formatLongDate(event.eventDate),
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppPalette.inputBorderColor,
                ),
                Expanded(
                  child: _DateBlock(
                    icon: Icons.schedule_rounded,
                    label: 'Registration Ends',
                    value: formatLongDate(event.registrationEndsAt),
                  ),
                ),
              ],
            ),
          ),

          if (event.eligibility.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.groups_outlined,
                  size: 22,
                  color: AppPalette.primaryBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Eligibility',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.primaryBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.eligibility,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppPalette.authTextSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.35,
                color: AppPalette.authTextPrimaryColor,
              ),
            ),
          ],

          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: _RegisterButton(
              registered: registered,
              registering: registering,
              open: open,
              onTap: onRegister,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppPalette.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.authTextSecondaryColor,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.authTextPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Register Now / Registered / Registration Closed
class _RegisterButton extends StatelessWidget {
  const _RegisterButton({
    required this.registered,
    required this.registering,
    required this.open,
    required this.onTap,
  });

  final bool registered;
  final bool registering;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 1) already registered (even if the registration is closed now)
    if (registered) {
      return _pill(
        color: AppPalette.successColor.withValues(alpha: 0.14),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 20, color: AppPalette.successColor),
            SizedBox(width: 8),
            Text(
              'Registered',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppPalette.successColor,
              ),
            ),
          ],
        ),
      );
    }

    // 2) registration date is over
    if (!open) {
      return _pill(
        color: AppPalette.inputBorderColor.withValues(alpha: 0.5),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 18, color: AppPalette.hintTextColor),
            SizedBox(width: 8),
            Text(
              'Registration Closed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppPalette.hintTextColor,
              ),
            ),
          ],
        ),
      );
    }

    // 3) open -> Register Now
    return _pill(
      gradient: AppPalette.primaryButtonGradient,
      onTap: registering ? null : onTap,
      child: registering
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppPalette.white,
              ),
            )
          : const Text(
              'Register Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppPalette.white,
              ),
            ),
    );
  }

  Widget _pill({
    required Widget child,
    Color? color,
    Gradient? gradient,
    VoidCallback? onTap,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 150),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
