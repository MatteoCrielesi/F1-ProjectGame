import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Circuito {
  final int id;
  final String nome;
  final String data;
  final String lunghezza;
  final int zoneDRS;
  final String recordQuali;
  final String pilotaQuali;
  final String annoQuali;
  final String recordGara;
  final String pilotaGara;
  final String annoGara;
  final String imageAsset;

  Circuito({
    required this.id,
    required this.nome,
    required this.data,
    required this.lunghezza,
    required this.zoneDRS,
    required this.recordQuali,
    required this.pilotaQuali,
    required this.annoQuali,
    required this.recordGara,
    required this.pilotaGara,
    required this.annoGara,
    required this.imageAsset,
  });
}

Future<List<Circuito>> fetchCalendario() async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    Circuito(
      id: 1, nome: 'Bahrain', data: '2 marzo 2025', lunghezza: '5.412 km', zoneDRS: 3,
      recordQuali: '1:29.179', pilotaQuali: 'Max Verstappen', annoQuali: '2024',
      recordGara: '1:31.447', pilotaGara: 'Pedro de la Rosa', annoGara: '2005',
      imageAsset: 'assets/circuiti/bahrain.svg',
    ),
    Circuito(
      id: 2, nome: 'Arabia Saudita', data: '9 marzo 2025', lunghezza: '6.174 km', zoneDRS: 3,
      recordQuali: '1:27.958', pilotaQuali: 'Sergio Perez', annoQuali: '2023',
      recordGara: '1:30.734', pilotaGara: 'Lewis Hamilton', annoGara: '2021',
      imageAsset: 'assets/circuiti/saudiarabia.svg',
    ),
    Circuito(
      id: 3, nome: 'Australia', data: '16 marzo 2025', lunghezza: '5.278 km', zoneDRS: 4,
      recordQuali: '1:15.096', pilotaQuali: 'Max Verstappen', annoQuali: '2025',
      recordGara: '1:19.813', pilotaGara: 'Pedro de la Rosa', annoGara: '2024',
      imageAsset: 'assets/circuiti/australia.svg',
    ),
    Circuito(
      id: 4, nome: 'Giappone', data: '6 aprile 2025', lunghezza: '5.807 km', zoneDRS: 2,
      recordQuali: '1:27.319', pilotaQuali: 'Max Verstappen', annoQuali: '2024',
      recordGara: '1:30.983', pilotaGara: 'Lewis Hamilton', annoGara: '2019',
      imageAsset: 'assets/circuiti/japan.svg',
    ),
    Circuito(
      id: 5, nome: 'Cina', data: '13 aprile 2025', lunghezza: '5.451 km', zoneDRS: 3,
      recordQuali: '1:31.095', pilotaQuali: 'Lewis Hamilton', annoQuali: '2024',
      recordGara: '1:32.573', pilotaGara: 'Michael Schumacher', annoGara: '2004',
      imageAsset: 'assets/circuiti/shanghai.svg',
    ),
    Circuito(
      id: 6, nome: 'Miami', data: '4 maggio 2025', lunghezza: '5.412 km', zoneDRS: 3,
      recordQuali: '1:26.841', pilotaQuali: 'Max Verstappen', annoQuali: '2023',
      recordGara: '1:29.708', pilotaGara: 'Max Verstappen', annoGara: '2023',
      imageAsset: 'assets/circuiti/usamiami.svg',
    ),
    Circuito(
      id: 7, nome: 'Emilia Romagna', data: '18 maggio 2025', lunghezza: '4.909 km', zoneDRS: 2,
      recordQuali: '1:14.746', pilotaQuali: 'Lewis Hamilton', annoQuali: '2020',
      recordGara: '1:15.484', pilotaGara: 'Lewis Hamilton', annoGara: '2020',
      imageAsset: 'assets/circuiti/italyimola.svg',
    ),
    Circuito(
      id: 8, nome: 'Monaco', data: '25 maggio 2025', lunghezza: '3.337 km', zoneDRS: 1,
      recordQuali: '1:10.166', pilotaQuali: 'Lewis Hamilton', annoQuali: '2019',
      recordGara: '1:12.909', pilotaGara: 'Max Verstappen', annoGara: '2021',
      imageAsset: 'assets/circuiti/monaco.svg',
    ),
    Circuito(
      id: 9, nome: 'Spagna', data: '1 giugno 2025', lunghezza: '4.675 km', zoneDRS: 2,
      recordQuali: '1:12.272', pilotaQuali: 'Max Verstappen', annoQuali: '2023',
      recordGara: '1:16.330', pilotaGara: 'Max Verstappen', annoGara: '2023',
      imageAsset: 'assets/circuiti/spain.svg',
    ),
    Circuito(
      id: 10, nome: 'Canada', data: '15 giugno 2025', lunghezza: '4.361 km', zoneDRS: 2,
      recordQuali: '1:20.245', pilotaQuali: 'Valtteri Bottas', annoQuali: '2019',
      recordGara: '1:13.078', pilotaGara: 'Sebastian Vettel', annoGara: '2019',
      imageAsset: 'assets/circuiti/canada.svg',
    ),
    Circuito(
      id: 11, nome: 'Austria', data: '29 giugno 2025', lunghezza: '4.318 km', zoneDRS: 3,
      recordQuali: '1:02.939', pilotaQuali: 'Carlos Sainz', annoQuali: '2020',
      recordGara: '1:05.619', pilotaGara: 'Max Verstappen', annoGara: '2021',
      imageAsset: 'assets/circuiti/austria.svg',
    ),
    Circuito(
      id: 12, nome: 'Gran Bretagna', data: '6 luglio 2025', lunghezza: '5.891 km', zoneDRS: 3,
      recordQuali: '1:25.093', pilotaQuali: 'Max Verstappen', annoQuali: '2020',
      recordGara: '1:27.097', pilotaGara: 'Max Verstappen', annoGara: '2020',
      imageAsset: 'assets/circuiti/greatbritain.svg',
    ),
    Circuito(
      id: 13, nome: 'Belgio', data: '27 luglio 2025', lunghezza: '7.004 km', zoneDRS: 2,
      recordQuali: '1:41.252', pilotaQuali: 'Lewis Hamilton', annoQuali: '2020',
      recordGara: '1:46.286', pilotaGara: 'Valtteri Bottas', annoGara: '2019',
      imageAsset: 'assets/circuiti/belgium.svg',
    ),
    Circuito(
      id: 14, nome: 'Ungheria', data: '3 agosto 2025', lunghezza: '4.381 km', zoneDRS: 2,
      recordQuali: '1:13.447', pilotaQuali: 'Lewis Hamilton', annoQuali: '2020',
      recordGara: '1:16.627', pilotaGara: 'Max Verstappen', annoGara: '2023',
      imageAsset: 'assets/circuiti/hungary.svg',
    ),
    Circuito(
      id: 15, nome: 'Olanda', data: '31 agosto 2025', lunghezza: '4.259 km', zoneDRS: 2,
      recordQuali: '1:10.567', pilotaQuali: 'Max Verstappen', annoQuali: '2021',
      recordGara: '1:11.097', pilotaGara: 'Lewis Hamilton', annoGara: '2021',
      imageAsset: 'assets/circuiti/netherlands.svg',
    ),
    Circuito(
      id: 16, nome: 'Italia', data: '7 settembre 2025', lunghezza: '5.793 km', zoneDRS: 2,
      recordQuali: '1:18.887', pilotaQuali: 'Carlos Sainz', annoQuali: '2020',
      recordGara: '1:21.046', pilotaGara: 'Rubens Barrichello', annoGara: '2004',
      imageAsset: 'assets/circuiti/italymonza.svg',
    ),
    Circuito(
      id: 17, nome: 'Azerbaijan', data: '21 settembre 2025', lunghezza: '6.003 km', zoneDRS: 2,
      recordQuali: '1:40.203', pilotaQuali: 'Charles Leclerc', annoQuali: '2019',
      recordGara: '1:43.009', pilotaGara: 'Max Verstappen', annoGara: '2023',
      imageAsset: 'assets/circuiti/azerbaijan.svg',
    ),
    Circuito(
      id: 18, nome: 'Singapore', data: '28 settembre 2025', lunghezza: '5.063 km', zoneDRS: 3,
      recordQuali: '1:35.867', pilotaQuali: 'Lewis Hamilton', annoQuali: '2018',
      recordGara: '1:41.905', pilotaGara: 'Kevin Magnussen', annoGara: '2018',
      imageAsset: 'assets/circuiti/singapore.svg',
    ),
    Circuito(
      id: 19, nome: 'Stati Uniti', data: '19 ottobre 2025', lunghezza: '5.513 km', zoneDRS: 3,
      recordQuali: '1:32.029', pilotaQuali: 'Charles Leclerc', annoQuali: '2019',
      recordGara: '1:36.169', pilotaGara: 'Charles Leclerc', annoGara: '2019',
      imageAsset: 'assets/circuiti/usacota.svg',
    ),
    Circuito(
      id: 20, nome: 'Messico', data: '26 ottobre 2025', lunghezza: '4.304 km', zoneDRS: 2,
      recordQuali: '1:14.758', pilotaQuali: 'Valtteri Bottas', annoQuali: '2019',
      recordGara: '1:17.774', pilotaGara: 'Valtteri Bottas', annoGara: '2019',
      imageAsset: 'assets/circuiti/mexico.svg',
    ),
    Circuito(
      id: 21, nome: 'Brasile', data: '2 novembre 2025', lunghezza: '4.309 km', zoneDRS: 2,
      recordQuali: '1:07.281', pilotaQuali: 'Max Verstappen', annoQuali: '2018',
      recordGara: '1:10.540', pilotaGara: 'Valtteri Bottas', annoGara: '2018',
      imageAsset: 'assets/circuiti/brazil.svg',
    ),
    Circuito(
      id: 22, nome: 'Las Vegas', data: '23 novembre 2025', lunghezza: '6.120 km', zoneDRS: 3,
      recordQuali: '1:32.029', pilotaQuali: 'Charles Leclerc', annoQuali: '2023',
      recordGara: '1:35.490', pilotaGara: 'Oscar Piastri', annoGara: '2023',
      imageAsset: 'assets/circuiti/usavegas.svg',
    ),
    Circuito(
      id: 23, nome: 'Qatar', data: '30 novembre 2025', lunghezza: '5.380 km', zoneDRS: 2,
      recordQuali: '1:20.827', pilotaQuali: 'Max Verstappen', annoQuali: '2023',
      recordGara: '1:24.319', pilotaGara: 'Max Verstappen', annoGara: '2023',
      imageAsset: 'assets/circuiti/qatar.svg',
    ),
    Circuito(
      id: 24, nome: 'Abu Dhabi', data: '7 dicembre 2025', lunghezza: '5.281 km', zoneDRS: 3,
      recordQuali: '1:34.779', pilotaQuali: 'Max Verstappen', annoQuali: '2020',
      recordGara: '1:39.283', pilotaGara: 'Max Verstappen', annoGara: '2021',
      imageAsset: 'assets/circuiti/abudhabi.svg',
    ),
  ];
}

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  late Future<List<Circuito>> futureCircuiti;
  int? expandedId;

  @override
  void initState() {
    super.initState();
    futureCircuiti = fetchCalendario();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 400;
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    const Color bordoRosso = Color(0xFF990000);
    const Color backgroundPanna = Color(0xFFF8F5EF);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario F1 2025', style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 18 : 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: const BackButton(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bordoRosso, Colors.black, Colors.black, bordoRosso],
            stops: [0, 0.12, 0.88, 1],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<Circuito>>(
            future: futureCircuiti,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.red));
              } else if (snapshot.hasError) {
                return Center(child: Text('Errore: ${snapshot.error}', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nessun circuito disponibile', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center));
              }
              
              final data = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 18),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final circuito = data[index];
                  final isExpanded = expandedId == circuito.id;
                  final borderRadius = isSmallScreen ? 14.0 : 18.0;
                  final padding = isExpanded 
                      ? (isSmallScreen ? 14.0 : isLargeScreen ? 24.0 : 20.0) 
                      : (isSmallScreen ? 10.0 : 14.0);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: isExpanded ? backgroundPanna : Colors.black.withOpacity(0.87),
                      borderRadius: BorderRadius.circular(borderRadius),
                      boxShadow: isExpanded ? [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 5))] : null,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(borderRadius),
                      onTap: () => setState(() => expandedId = isExpanded ? null : circuito.id),
                      child: Padding(
                        padding: EdgeInsets.all(padding),
                        child: isExpanded 
                            ? _buildExpandedView(circuito, isSmallScreen, isLargeScreen)
                            : _buildCollapsedView(circuito, isSmallScreen),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedView(Circuito circuito, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: Text(circuito.nome, style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
        ),
        Text(circuito.data, style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.white70), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildExpandedView(Circuito circuito, bool isSmallScreen, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSmallScreen) _buildSmallScreenHeader(circuito) else _buildLargeScreenHeader(circuito, isLargeScreen),
        const SizedBox(height: 16),
        const Divider(color: Colors.black26),
        const SizedBox(height: 12),
        isSmallScreen 
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildDetailFields(circuito, isSmallScreen))
            : Wrap(spacing: isLargeScreen ? 30 : 25, runSpacing: isLargeScreen ? 16 : 12, children: _buildDetailFields(circuito, isSmallScreen)),
      ],
    );
  }

  Widget _buildSmallScreenHeader(Circuito circuito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(circuito.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Text(circuito.data, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 12),
        SizedBox(height: 120, child: _buildCircuitImage(circuito)),
      ],
    );
  }

  Widget _buildLargeScreenHeader(Circuito circuito, bool isLargeScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: isLargeScreen ? 120 : 90, height: isLargeScreen ? 120 : 90, child: _buildCircuitImage(circuito)),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(circuito.nome, style: TextStyle(fontSize: isLargeScreen ? 28 : 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 6),
              Text(circuito.data, style: TextStyle(fontSize: isLargeScreen ? 18 : 16, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircuitImage(Circuito circuito) {
    return SvgPicture.asset(
      circuito.imageAsset,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)),
    );
  }

  List<Widget> _buildDetailFields(Circuito circuito, bool isSmallScreen) {
    return [
      _detailField('Lunghezza', circuito.lunghezza, isSmallScreen),
      _detailField('Zone DRS', circuito.zoneDRS.toString(), isSmallScreen),
      _detailField('Record Qualifica', '${circuito.recordQuali} (${circuito.pilotaQuali}, ${circuito.annoQuali})', isSmallScreen),
      _detailField('Record Gara', '${circuito.recordGara} (${circuito.pilotaGara}, ${circuito.annoGara})', isSmallScreen),
    ];
  }

  Widget _detailField(String label, String value, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: isSmallScreen ? 14 : 16)),
        Expanded(child: Text(value, style: TextStyle(color: Colors.black87, fontSize: isSmallScreen ? 14 : 16), softWrap: true)),
      ],
    );
  }
}