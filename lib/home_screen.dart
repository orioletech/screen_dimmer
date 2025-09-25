import 'dart:io';
import 'dart:async';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
// Components.
import 'components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _TopTab { controls, about }

class _HomeScreenState extends State<HomeScreen> {
  // --- State for custom tabs ---
  _TopTab _currentTab = _TopTab.controls;

  // Brightness
  static const double _minBrightness = 10.0;
  static const double _maxBrightness = 100.0;

  // CHANGE: start at neutral (no change) so the UI matches a cleared redshift
  double _brightnessValue = 100.0;

  // Temperature in Kelvin (typical display range)
  static const double _minTempK = 1000.0;
  static const double _maxTempK = 10000.0;
  double _temperatureValue = 6500.0; // neutral daylight

  // Gamma (typical useful range)
  static const double _minGamma = 1.0;
  static const double _maxGamma = 3.0;

  // CHANGE: start at neutral gamma so no color shift
  double _gammaValue = 1.0;

  // Debounce timer so we don't hammer the system with commands while dragging.
  static const Duration _applyDelay = Duration(milliseconds: 250);
  Timer? _debounceTimer;

  bool _redshiftAvailable = false;
  String? _lastError;

  // Cache last applied values to skip redundant commands
  int? _lastTempK;
  double? _lastBrightnessFactor;
  String? _lastGammaArg;

  @override
  void initState() {
    super.initState();
    _checkRedshift();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // CHANGE: helper to align UI and caches to neutral (no-op) values
  void _setNeutralUiAndCache() {
    const int neutralTemp = 6500;
    const double neutralBrightnessFactor = 1.0;
    const String neutralGammaArg = '1.00:1.00:1.00';

    setState(() {
      _brightnessValue = 100.0;
      _temperatureValue = neutralTemp.toDouble();
      _gammaValue = 1.0;

      // Prime the "last applied" cache to neutral so _applySettings()
      // won't do anything until the user moves a slider.
      _lastTempK = neutralTemp;
      _lastBrightnessFactor = neutralBrightnessFactor;
      _lastGammaArg = neutralGammaArg;
    });
  }

  Future<void> _checkRedshift() async {
    if (!Platform.isLinux) {
      setState(() {
        _redshiftAvailable = false;
        _lastError = 'Redshift control is only supported on Linux.';
      });
      return;
    }

    try {
      final which = await Process.run('which', ['redshift']);
      setState(() {
        _redshiftAvailable = which.exitCode == 0;
        if (!_redshiftAvailable) {
          _lastError =
              'Redshift not found. Install it (e.g. `sudo apt install redshift`)';
        }
      });

      if (_redshiftAvailable) {
        // Clear any previous adjustments so the user sees *no* change.
        await Process.run('redshift', ['-x']);

        // CHANGE: Align UI & cache to neutral and DO NOT apply anything here.
        _setNeutralUiAndCache();
      }
    } catch (e) {
      setState(() {
        _redshiftAvailable = false;
        _lastError = 'Failed to check Redshift: $e';
      });
    }
  }

  void _scheduleApply() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_applyDelay, _applySettings);
  }

  Future<void> _applySettings() async {
    if (!_redshiftAvailable) return;

    // Sanitize / clamp values
    final int tempK = _temperatureValue.round().clamp(
      _minTempK.toInt(),
      _maxTempK.toInt(),
    );
    final double brightnessFactor = (_brightnessValue / 100.0).clamp(0.1, 1.0);
    final double gamma = _gammaValue.clamp(_minGamma, _maxGamma);
    final String gammaArg =
        '${gamma.toStringAsFixed(2)}:${gamma.toStringAsFixed(2)}:${gamma.toStringAsFixed(2)}';

    // Skip if unchanged (within sensible tolerance)
    const double eps = 0.001;
    if (_lastTempK == tempK &&
        _lastGammaArg == gammaArg &&
        _lastBrightnessFactor != null &&
        (brightnessFactor - (_lastBrightnessFactor ?? 0.0)).abs() < eps) {
      return;
    }

    try {
      // Build redshift args
      final args = [
        '-r',
        '-P',
        '-O',
        '$tempK',
        '-b',
        '${brightnessFactor.toStringAsFixed(2)}:${brightnessFactor.toStringAsFixed(2)}',
        '-g',
        gammaArg,
      ];

      final result = await Process.run('redshift', args);

      if (result.exitCode != 0) {
        setState(() {
          _lastError = 'redshift failed (${result.exitCode}): ${result.stderr}';
        });
        return;
      }

      // Success: cache last applied values
      setState(() {
        _lastTempK = tempK;
        _lastBrightnessFactor = brightnessFactor;
        _lastGammaArg = gammaArg;
        _lastError = null;
      });
    } catch (e) {
      setState(() {
        _lastError = 'Failed to apply settings: $e';
      });
    }
  }

  Future<void> _resetRedshift() async {
    if (!_redshiftAvailable) return;
    try {
      await Process.run('redshift', ['-x']); // clear adjustments

      // CHANGE: keep the screen at neutral and sync UI/caches accordingly.
      _setNeutralUiAndCache();

      // Do NOT call _applySettings() here; we want to remain neutral until user changes sliders.
    } catch (e) {
      setState(() {
        _lastError = 'Reset failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Screen Dimmer',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        backgroundColor: NeumorphicTheme.baseColor(context),
        elevation: 0,
      ),
      body: Column(
        children: [
          Text(
            'An extra bit of comfort.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          _buildNeumorphicTabs(context),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _currentTab == _TopTab.controls
                    ? KeyedSubtree(
                        key: const ValueKey('controls'),
                        child: _buildControls(context),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('about'),
                        child: _buildAbout(context),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Custom Neumorphic tabs ----------
  Widget _buildNeumorphicTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: _neumorphicTab(
              label: 'Controls',
              selected: _currentTab == _TopTab.controls,
              onTap: () => setState(() => _currentTab = _TopTab.controls),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _neumorphicTab(
              label: 'About',
              selected: _currentTab == _TopTab.about,
              onTap: () => setState(() => _currentTab = _TopTab.about),
            ),
          ),
        ],
      ),
    );
  }

  Widget _neumorphicTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final textStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.w600);

    return GestureDetector(
      onTap: onTap,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(100)),
          depth: selected ? -6 : 6, // depressed when selected
          intensity: 0.9,
        ),
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Center(child: Text(label, style: textStyle)),
      ),
    );
  }

  // ---------- Tabs content ----------
  Widget _buildControls(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            if (!_redshiftAvailable) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    _lastError ?? 'Redshift unavailable',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              UnderlinedText(
                text: 'View on GitHub',
                textStyle: Theme.of(context).textTheme.bodyMedium,
                underlineColor: Colors.black,
                onTap: () {
                  final uri = Uri.parse('https://github.com/jonls/redshift');
                  launchUrlFunction(url: uri.toString());
                },
              ),
              const SizedBox(height: 40),
            ],

            // Brightness
            Row(
              children: [
                Icon(
                  Icons.brightness_6_rounded,
                  size: 25,
                  color: NeumorphicTheme.defaultTextColor(context),
                ),
                const SizedBox(width: 8),
                Text('Brightness', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  "${_brightnessValue.toInt()}%",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Neumorphic(
              padding: const EdgeInsets.all(20),
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    '${_minBrightness.toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Slider(
                      value: _brightnessValue,
                      onChanged: (newValue) {
                        setState(() {
                          _brightnessValue = newValue;
                        });
                        _scheduleApply();
                      },
                      onChangeEnd: (_) => _scheduleApply(),
                      min: _minBrightness,
                      max: _maxBrightness,
                    ),
                  ),
                  Text(
                    '${_maxBrightness.toInt()}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Temperature
            Row(
              children: [
                Icon(
                  Icons.thermostat_rounded,
                  size: 25,
                  color: NeumorphicTheme.defaultTextColor(context),
                ),
                const SizedBox(width: 8),
                Text('Temperature', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  '${_temperatureValue.round()}K',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Neumorphic(
              padding: const EdgeInsets.all(20),
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    '${_minTempK.toInt()}K',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Slider(
                      value: _temperatureValue,
                      onChanged: (newValue) {
                        setState(() {
                          _temperatureValue = newValue;
                        });
                        _scheduleApply();
                      },
                      onChangeEnd: (_) => _scheduleApply(),
                      min: _minTempK,
                      max: _maxTempK,
                    ),
                  ),
                  Text(
                    '${_maxTempK.toInt()}K',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Gamma
            Row(
              children: [
                Icon(
                  Icons.auto_graph_rounded,
                  size: 25,
                  color: NeumorphicTheme.defaultTextColor(context),
                ),
                const SizedBox(width: 8),
                Text('Gamma', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  _gammaValue.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Neumorphic(
              padding: const EdgeInsets.all(20),
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    _minGamma.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Slider(
                      value: _gammaValue,
                      onChanged: (newValue) {
                        setState(() {
                          _gammaValue = newValue;
                        });
                        _scheduleApply();
                      },
                      onChangeEnd: (_) => _scheduleApply(),
                      min: _minGamma,
                      max: _maxGamma,
                    ),
                  ),
                  Text(
                    _maxGamma.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reset
            NeumorphicButton(
              onPressed: _resetRedshift,
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(100)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 25,
                    color: NeumorphicTheme.defaultTextColor(context),
                  ),
                  const SizedBox(width: 5),
                  Text('Reset', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAbout(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyMedium;
    final title = Theme.of(context).textTheme.titleMedium;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Redshift', style: title),
            const SizedBox(height: 8),
            Text(
              '• Requires Linux with Redshift installed.\n'
              '• “Reset” clears adjustments and returns to neutral (6500K, 100% brightness, gamma 1.0).\n'
              '• Changes are only applied after a short pause to keep things smooth (avoid overly calling terminal commands).',
              style: body,
            ),
            const SizedBox(height: 16),
            UnderlinedText(
              text: 'Get Redshift on GitHub',
              textStyle: body,
              underlineColor: Colors.black,
              onTap: () => launchUrlFunction(url: 'https://github.com/jonls/redshift'),
            ),

            const SizedBox(height: 20),

            Text('About Screen Dimmer', style: title),
            const SizedBox(height: 8),
            Text(
              "Screen Dimmer provides quick controls for display comfort using the Redshift tool on Linux. Adjust brightness, color temperature, and gamma with easy sliders.\n\nI take no credit for the Redshift tool itself; I just wanted a simple GUI for it.\n\nI've only tested this on Linux Mint 22 so milage may vary elsewhere.",
              style: body,
            ),
            const SizedBox(height: 16),

            Text('How it works', style: title),
            const SizedBox(height: 8),
            Text(
              '• Brightness: scales the display luminance (10%–100%). Avoided 0% as I found I accidently could turn the screen black and be unable to see anything to turn it back up!\n'
              '• Temperature: sets color temperature in Kelvin (1000–10000K).\n'
              '• Gamma: applies a uniform gamma curve (1.0–3.0).',
              style: body,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
