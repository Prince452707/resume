// import 'package:flutter/material.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:printing/printing.dart';
// import 'dart:io';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Resume Maker',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: ResumeMaker(),
//     );
//   }
// }

// class ResumeMaker extends StatefulWidget {
//   @override
//   _ResumeMakerState createState() => _ResumeMakerState();
// }

// class _ResumeMakerState extends State<ResumeMaker> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _summaryController = TextEditingController();
//   final TextEditingController _experienceController = TextEditingController();
//   final TextEditingController _educationController = TextEditingController();
//   final TextEditingController _skillsController = TextEditingController();

//   bool _isLoading = false;
//   late GenerativeModel _model;

//   @override
//   void initState() {
//     super.initState();
//     _model = GenerativeModel(
//       model: 'gemini-pro',
//       apiKey: 'AIzaSyALPelkD_VVKoYNVzk1XuKadvpDayOQw1Y',
//     );
//   }

//   Future<void> _enhanceWithAI() async {
//     setState(() => _isLoading = true);
//     try {
//       final jobTitle = await _showInputDialog('Enter your desired job title');
//       if (jobTitle == null) return;

//       _summaryController.text = await _generateAIContent(
//         'Enhance this professional summary for a $jobTitle resume, keeping it concise and impactful: ${_summaryController.text}'
//       );
//       _experienceController.text = await _generateAIContent(
//         'Enhance these work experiences for a $jobTitle resume, improving the achievements and impact: ${_experienceController.text}'
//       );
//       _skillsController.text = await _generateAIContent(
//         'Enhance this skills list for a $jobTitle resume, ensuring relevance and impact: ${_skillsController.text}'
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<String> _generateAIContent(String prompt) async {
//     final content = await _model.generateContent([Content.text(prompt)]);
//     return content.text ?? 'Error enhancing content. Please try again.';
//   }

//   Future<String?> _showInputDialog(String title) async {
//     String? input;
//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: TextField(
//           onChanged: (value) => input = value,
//           decoration: InputDecoration(hintText: "Enter your input here"),
//         ),
//         actions: [
//           TextButton(
//             child: Text('Cancel'),
//             onPressed: () => Navigator.pop(context),
//           ),
//           TextButton(
//             child: Text('OK'),
//             onPressed: () => Navigator.pop(context, input),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _previewPdf() async {
//     final pdf = await _generatePdf();
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(title: Text('Resume Preview')),
//           body: PdfPreview(
//             build: (format) => pdf.save(),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _downloadPdf() async {
//     final pdf = await _generatePdf();
//     final status = await Permission.storage.request();
//     if (status.isGranted) {
//       final output = await getExternalStorageDirectory();
//       final file = File('${output?.path}/resume.pdf');
//       await file.writeAsBytes(await pdf.save());

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('PDF saved to ${file.path}')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Permission denied to save PDF')),
//       );
//     }
//   }

//   Future<pw.Document> _generatePdf() async {
//     final pdf = pw.Document();
//     final font = await PdfGoogleFonts.nunitoExtraLight();
//     final boldFont = await PdfGoogleFonts.nunitoBold();

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(_nameController.text, style: pw.TextStyle(font: boldFont, fontSize: 24)),
//               pw.SizedBox(height: 10),
//               pw.Text('${_emailController.text} | ${_phoneController.text}', style: pw.TextStyle(font: font, fontSize: 12)),
//               pw.SizedBox(height: 20),
//               pw.Text('Professional Summary', style: pw.TextStyle(font: boldFont, fontSize: 18)),
//               pw.Text(_summaryController.text, style: pw.TextStyle(font: font, fontSize: 12)),
//               pw.SizedBox(height: 20),
//               pw.Text('Experience', style: pw.TextStyle(font: boldFont, fontSize: 18)),
//               pw.Text(_experienceController.text, style: pw.TextStyle(font: font, fontSize: 12)),
//               pw.SizedBox(height: 20),
//               pw.Text('Education', style: pw.TextStyle(font: boldFont, fontSize: 18)),
//               pw.Text(_educationController.text, style: pw.TextStyle(font: font, fontSize: 12)),
//               pw.SizedBox(height: 20),
//               pw.Text('Skills', style: pw.TextStyle(font: boldFont, fontSize: 18)),
//               pw.Text(_skillsController.text, style: pw.TextStyle(font: font, fontSize: 12)),
//             ],
//           );
//         },
//       ),
//     );
//     return pdf;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Resume Maker')),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
//             TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
//             TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone')),
//             SizedBox(height: 20),
//             Text('Professional Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             TextField(controller: _summaryController, maxLines: 5),
//             SizedBox(height: 20),
//             Text('Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             TextField(controller: _experienceController, maxLines: 10),
//             SizedBox(height: 20),
//             Text('Education', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             TextField(controller: _educationController, maxLines: 5),
//             SizedBox(height: 20),
//             Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             TextField(controller: _skillsController, maxLines: 5),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _enhanceWithAI,
//               child: _isLoading ? CircularProgressIndicator() : Text('Enhance with AI'),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _previewPdf,
//               child: Text('Preview Resume'),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _downloadPdf,
//               child: Text('Download Resume as PDF'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:printing/printing.dart';
// import 'dart:io';
// import 'package:url_launcher/url_launcher.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Advanced Resume Maker',
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//         hintColor: Colors.amberAccent,
//         fontFamily: 'Roboto',
//         textTheme: TextTheme(
//           displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//           displayMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
//           bodyLarge: TextStyle(fontSize: 16.0),
//         ),
//       ),
//       debugShowCheckedModeBanner: false,
//       home: ResumeMaker(),
//     );
//   }
// }

// class ResumeMaker extends StatefulWidget {
//   @override
//   _ResumeMakerState createState() => _ResumeMakerState();
// }

// class _ResumeMakerState extends State<ResumeMaker> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _linkedinController = TextEditingController();
//   final TextEditingController _githubController = TextEditingController();
//   final TextEditingController _portfolioController = TextEditingController();
//   final TextEditingController _summaryController = TextEditingController();
//   final TextEditingController _experienceController = TextEditingController();
//   final TextEditingController _educationController = TextEditingController();
//   final TextEditingController _skillsController = TextEditingController();
//   final TextEditingController _projectsController = TextEditingController();
//   final TextEditingController _awardsController = TextEditingController();

//   bool _isLoading = false;
//   late GenerativeModel _model;

//   @override
//   void initState() {
//     super.initState();
//     _model = GenerativeModel(
//       model: 'gemini-pro',
//       apiKey: 'AIzaSyALPelkD_VVKoYNVzk1XuKadvpDayOQw1Y',
//     );
//   }

//   Future<void> _enhanceWithAI() async {
//     setState(() => _isLoading = true);
//     try {
//       final jobTitle = await _showInputDialog('Enter your desired job title');
//       if (jobTitle == null) return;

//       _summaryController.text = await _generateAIContent(
//         'Enhance this professional summary for a $jobTitle resume, keeping it concise and impactful: ${_summaryController.text}'
//       );
//       _experienceController.text = await _generateAIContent(
//         'Enhance these work experiences for a $jobTitle resume, improving the achievements and impact: ${_experienceController.text}'
//       );
//       _skillsController.text = await _generateAIContent(
//         'Enhance this skills list for a $jobTitle resume, ensuring relevance and impact: ${_skillsController.text}'
//       );
//       _projectsController.text = await _generateAIContent(
//         'Enhance these project descriptions for a $jobTitle resume, highlighting key technologies and outcomes: ${_projectsController.text}'
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<String> _generateAIContent(String prompt) async {
//     final content = await _model.generateContent([Content.text(prompt)]);
//     return content.text ?? 'Error enhancing content. Please try again.';
//   }

//   Future<String?> _showInputDialog(String title) async {
//     String? input;
//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: TextField(
//           onChanged: (value) => input = value,
//           decoration: InputDecoration(hintText: "Enter your input here"),
//         ),
//         actions: [
//           TextButton(
//             child: Text('Cancel'),
//             onPressed: () => Navigator.pop(context),
//           ),
//           TextButton(
//             child: Text('OK'),
//             onPressed: () => Navigator.pop(context, input),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _previewPdf() async {
//     final pdf = await _generatePdf();
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(title: Text('Resume Preview')),
//           body: PdfPreview(
//             build: (format) => pdf.save(),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _downloadPdf() async {
//     final pdf = await _generatePdf();
//     final status = await Permission.storage.request();
//     if (status.isGranted) {
//       final output = await getExternalStorageDirectory();
//       final file = File('${output?.path}/advanced_resume.pdf');
//       await file.writeAsBytes(await pdf.save());

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('PDF saved to ${file.path}')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Permission denied to save PDF')),
//       );
//     }
//   }

//   Future<pw.Document> _generatePdf() async {
//     final pdf = pw.Document();
//     final headingFont = await PdfGoogleFonts.nunitoBold();
//     final bodyFont = await PdfGoogleFonts.nunitoRegular();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: pw.EdgeInsets.all(32),
//         build: (pw.Context context) {
//           return [
//             pw.Header(
//               level: 0,
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(_nameController.text, style: pw.TextStyle(font: headingFont, fontSize: 28)),
//                       pw.SizedBox(height: 5),
//                       pw.Text(_emailController.text, style: pw.TextStyle(font: bodyFont, fontSize: 12)),
//                       pw.Text(_phoneController.text, style: pw.TextStyle(font: bodyFont, fontSize: 12)),
//                     ],
//                   ),
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.Text('LinkedIn: ${_linkedinController.text}', style: pw.TextStyle(font: bodyFont, fontSize: 12)),
//                       pw.Text('GitHub: ${_githubController.text}', style: pw.TextStyle(font: bodyFont, fontSize: 12)),
//                       pw.Text('Portfolio: ${_portfolioController.text}', style: pw.TextStyle(font: bodyFont, fontSize: 12)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             pw.Header(level: 1, text: 'Professional Summary'),
//             pw.Paragraph(text: _summaryController.text),
//             pw.Header(level: 1, text: 'Experience'),
//             pw.Paragraph(text: _experienceController.text),
//             pw.Header(level: 1, text: 'Education'),
//             pw.Paragraph(text: _educationController.text),
//             pw.Header(level: 1, text: 'Skills'),
//             pw.Paragraph(text: _skillsController.text),
//             pw.Header(level: 1, text: 'Projects'),
//             pw.Paragraph(text: _projectsController.text),
//             pw.Header(level: 1, text: 'Awards and Achievements'),
//             pw.Paragraph(text: _awardsController.text),
//           ];
//         },
//       ),
//     );
//     return pdf;
//   }

//   Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//           filled: true,
//           fillColor: Colors.grey[200],
//         ),
//         maxLines: maxLines,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Advanced Resume Maker'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.info_outline),
//             onPressed: () => _showInfoDialog(context),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildTextField(_nameController, 'Full Name'),
//             _buildTextField(_emailController, 'Email'),
//             _buildTextField(_phoneController, 'Phone'),
//             _buildTextField(_linkedinController, 'LinkedIn Profile URL'),
//             _buildTextField(_githubController, 'GitHub Profile URL'),
//             _buildTextField(_portfolioController, 'Portfolio Website URL'),
//             SizedBox(height: 20),
//             Text('Professional Summary', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_summaryController, 'Summary', maxLines: 5),
//             SizedBox(height: 20),
//             Text('Experience', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_experienceController, 'Work Experience', maxLines: 10),
//             SizedBox(height: 20),
//             Text('Education', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_educationController, 'Education', maxLines: 5),
//             SizedBox(height: 20),
//             Text('Skills', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_skillsController, 'Skills', maxLines: 5),
//             SizedBox(height: 20),
//             Text('Projects', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_projectsController, 'Projects', maxLines: 10),
//             SizedBox(height: 20),
//             Text('Awards and Achievements', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_awardsController, 'Awards', maxLines: 5),
//             SizedBox(height: 20),
//             Center(
//               child: Wrap(
//                 spacing: 10,
//                 runSpacing: 10,
//                 children: [
//                   ElevatedButton.icon(
//                     icon: Icon(Icons.auto_awesome),
//                     label: Text('Enhance with AI'),
//                     onPressed: _isLoading ? null : _enhanceWithAI,
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.black, backgroundColor: Theme.of(context).colorScheme.secondary,
//                     ),
//                   ),
//                   ElevatedButton.icon(
//                     icon: Icon(Icons.preview),
//                     label: Text('Preview Resume'),
//                     onPressed: _previewPdf,
//                   ),
//                   ElevatedButton.icon(
//                     icon: Icon(Icons.download),
//                     label: Text('Download Resume'),
//                     onPressed: _downloadPdf,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showInfoDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('About Advanced Resume Maker'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('This app helps you create a professional resume with ease.'),
//                 Text('Fill in your details, enhance them with AI, and generate a PDF resume.'),
//                 SizedBox(height: 10),
//                 Text('Created by: Your Name'),
//                 Text('Version: 1.0.0'),
//                 SizedBox(height: 10),
//                 InkWell(
//                   child: Text('Visit our website', style: TextStyle(color: Colors.blue)),
//                   onTap: () => launch('https://www.example.com'),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:printing/printing.dart';
// import 'dart:io';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Advanced Resume Maker',
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//         hintColor: Colors.amberAccent,
//         fontFamily: 'Roboto',
//         textTheme: const TextTheme(
//           displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//           displayMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
//           bodyLarge: TextStyle(fontSize: 16.0),
//         ),
//       ),
//       debugShowCheckedModeBanner: false,
//       home: const ResumeMaker(),
//     );
//   }
// }

// class ResumeMaker extends StatefulWidget {
//   const ResumeMaker({super.key});

//   @override
//   _ResumeMakerState createState() => _ResumeMakerState();
// }

// class _ResumeMakerState extends State<ResumeMaker> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _linkedinController = TextEditingController();
//   final TextEditingController _githubController = TextEditingController();
//   final TextEditingController _portfolioController = TextEditingController();
//   final TextEditingController _summaryController = TextEditingController();
//   final TextEditingController _experienceController = TextEditingController();
//   final TextEditingController _educationController = TextEditingController();
//   final TextEditingController _skillsController = TextEditingController();
//   final TextEditingController _projectsController = TextEditingController();
//   final TextEditingController _awardsController = TextEditingController();

//   bool _isLoading = false;
//   late GenerativeModel _model;

//   @override
//   void initState() {
//     super.initState();
//     _model = GenerativeModel(
//       model: 'gemini-pro',
//       apiKey: 'AIzaSyALPelkD_VVKoYNVzk1XuKadvpDayOQw1Y',
//     );
//   }

//   Future<void> _enhanceWithAI() async {
//     setState(() => _isLoading = true);
//     try {
//       final jobTitle = await _showInputDialog('Enter your desired job title');
//       if (jobTitle == null) return;

//       _summaryController.text = await _generateAIContent(
//         'Enhance this professional summary for a $jobTitle resume, keeping it concise and impactful: ${_summaryController.text}'
//       );
//       _experienceController.text = await _generateAIContent(
//         'Enhance these work experiences for a $jobTitle resume, improving the achievements and impact: ${_experienceController.text}'
//       );
//       _skillsController.text = await _generateAIContent(
//         'Enhance this skills list for a $jobTitle resume, ensuring relevance and impact: ${_skillsController.text}'
//       );
//       _projectsController.text = await _generateAIContent(
//         'Enhance these project descriptions for a $jobTitle resume, highlighting key technologies and outcomes: ${_projectsController.text}'
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<String> _generateAIContent(String prompt) async {
//     final content = await _model.generateContent([Content.text(prompt)]);
//     return content.text ?? 'Error enhancing content. Please try again.';
//   }

//   Future<String?> _showInputDialog(String title) async {
//     String? input;
//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: TextField(
//           onChanged: (value) => input = value,
//           decoration: const InputDecoration(hintText: "Enter your input here"),
//         ),
//         actions: [
//           TextButton(
//             child: const Text('Cancel'),
//             onPressed: () => Navigator.pop(context),
//           ),
//           TextButton(
//             child: const Text('OK'),
//             onPressed: () => Navigator.pop(context, input),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _previewPdf() async {
//     final pdf = await _generatePdf();
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(title: const Text('Resume Preview')),
//           body: PdfPreview(
//             build: (format) => pdf.save(),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _downloadPdf() async {
//     final pdf = await _generatePdf();
//     final status = await Permission.storage.request();
//     if (status.isGranted) {
//       final output = await getExternalStorageDirectory();
//       final file = File('${output?.path}/advanced_resume.pdf');
//       await file.writeAsBytes(await pdf.save());

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('PDF saved to ${file.path}')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Permission denied to save PDF')),
//       );
//     }
//   }

//   Future<pw.Document> _generatePdf() async {
//     final pdf = pw.Document();
//     final headingFont = await PdfGoogleFonts.nunitoBold();
//     final bodyFont = await PdfGoogleFonts.nunitoRegular();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (pw.Context context) {
//           return [
//             pw.Header(
//               level: 0,
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(_nameController.text, style: pw.TextStyle(font: headingFont, fontSize: 28)),
//                       pw.SizedBox(height: 5),
//                       pw.Text(_emailController.text, style: pw.TextStyle(font: bodyFont, fontSize: 12)),
//                       pw.Text(_phoneController.text, style: pw.TextStyle(font: bodyFont, fontSize: 12)),
//                     ],
//                   ),
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.Text('LinkedIn: ${_linkedinController.text}', style: pw.TextStyle(font: bodyFont, fontSize: 12)),
//                       pw.Text('GitHub: ${_githubController.text}', style: pw.TextStyle(font: bodyFont, fontSize: 12)),
//                       pw.Text('Portfolio: ${_portfolioController.text}', style: pw.TextStyle(font: bodyFont, fontSize: 12)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             pw.Header(level: 1, text: 'Professional Summary'),
//             pw.Paragraph(text: _summaryController.text),
//             pw.Header(level: 1, text: 'Experience'),
//             pw.Paragraph(text: _experienceController.text),
//             pw.Header(level: 1, text: 'Education'),
//             pw.Paragraph(text: _educationController.text),
//             pw.Header(level: 1, text: 'Skills'),
//             pw.Paragraph(text: _skillsController.text),
//             pw.Header(level: 1, text: 'Projects'),
//             pw.Paragraph(text: _projectsController.text),
//             pw.Header(level: 1, text: 'Awards and Achievements'),
//             pw.Paragraph(text: _awardsController.text),
//           ];
//         },
//       ),
//     );
//     return pdf;
//   }

//   Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//           filled: true,
//           fillColor: Colors.grey[200],
//         ),
//         maxLines: maxLines,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Advanced Resume Maker'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: () => _showInfoDialog(context),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildTextField(_nameController, 'Full Name'),
//             _buildTextField(_emailController, 'Email'),
//             _buildTextField(_phoneController, 'Phone'),
//             _buildTextField(_linkedinController, 'LinkedIn Profile URL'),
//             _buildTextField(_githubController, 'GitHub Profile URL'),
//             _buildTextField(_portfolioController, 'Portfolio Website URL'),
//             const SizedBox(height: 20),
//             Text('Professional Summary', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_summaryController, 'Summary', maxLines: 5),
//             const SizedBox(height: 20),
//             Text('Experience', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_experienceController, 'Work Experience', maxLines: 10),
//             const SizedBox(height: 20),
//             Text('Education', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_educationController, 'Education', maxLines: 5),
//             const SizedBox(height: 20),
//             Text('Skills', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_skillsController, 'Skills', maxLines: 5),
//             const SizedBox(height: 20),
//             Text('Projects', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_projectsController, 'Projects', maxLines: 10),
//             const SizedBox(height: 20),
//             Text('Awards and Achievements', style: Theme.of(context).textTheme.titleLarge),
//             _buildTextField(_awardsController, 'Awards', maxLines: 5),
//             const SizedBox(height: 20),
//             Center(
//               child: Wrap(
//                 spacing: 10,
//                 runSpacing: 10,
//                 children: [
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.auto_awesome),
//                     label: const Text('Enhance with AI'),
//                     onPressed: _isLoading ? null : _enhanceWithAI,
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.black, backgroundColor: Theme.of(context).colorScheme.secondary,
//                     ),
//                   ),
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.preview),
//                     label: const Text('Preview Resume'),
//                     onPressed: _previewPdf,
//                   ),
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.download),
//                     label: const Text('Download Resume'),
//                     onPressed: _downloadPdf,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showInfoDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('About Advanced Resume Maker'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 const MarkdownBody(
//                   data: '''
// # Advanced Resume Maker

// This app helps you create a professional resume with ease.

// ## Features:
// - Fill in your details
// - Enhance content with AI
// - Generate a PDF resume

// Created by: Your Name
// Version: 1.1.0

// [Visit our website](https://www.example.com)

// **GitHub Repository:** [Advanced Resume Maker](https://github.com/yourusername/advanced-resume-maker)
//                   ''',
//                   selectable: true,
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   child: const Text('View on GitHub'),
//                   onPressed: () => launch('https://github.com/yourusername/advanced-resume-maker'),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }















import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Resume Maker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        hintColor: Colors.amberAccent,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16.0),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const ResumeMaker(),
    );
  }
}

class ResumeMaker extends StatefulWidget {
  const ResumeMaker({super.key});

  @override
  _ResumeMakerState createState() => _ResumeMakerState();
}

class _ResumeMakerState extends State<ResumeMaker> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _projectsController = TextEditingController();
  final TextEditingController _awardsController = TextEditingController();

  bool _isLoading = false;
  late GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'AIzaSyALPelkD_VVKoYNVzk1XuKadvpDayOQw1Y', // Replace with your actual API key
    );
  }

  Future<void> _enhanceWithAI() async {
    setState(() => _isLoading = true);
    try {
      final jobTitle = await _showInputDialog('Enter your desired job title');
      if (jobTitle == null) return;

      _summaryController.text = await _generateAIContent(
        'Enhance this professional summary for a $jobTitle resume, keeping it concise and impactful. Use **bold** for emphasis instead of asterisks: ${_summaryController.text}'
      );
      _experienceController.text = await _generateAIContent(
        'Enhance these work experiences for a $jobTitle resume, improving the achievements and impact. Use **bold** for emphasis instead of asterisks: ${_experienceController.text}'
      );
      _skillsController.text = await _generateAIContent(
        'Enhance this skills list for a $jobTitle resume, ensuring relevance and impact. Use **bold** for emphasis instead of asterisks: ${_skillsController.text}'
      );
      _projectsController.text = await _generateAIContent(
        'Enhance these project descriptions for a $jobTitle resume, highlighting key technologies and outcomes. Use **bold** for emphasis instead of asterisks: ${_projectsController.text}'
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _generateAIContent(String prompt) async {
    final content = await _model.generateContent([Content.text(prompt)]);
    return content.text?.replaceAll('*', '') ?? 'Error enhancing content. Please try again.';
  }

  Future<String?> _showInputDialog(String title) async {
    String? input;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          onChanged: (value) => input = value,
          decoration: const InputDecoration(hintText: "Enter your input here"),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context, input),
          ),
        ],
      ),
    );
  }

  Future<void> _previewPdf() async {
    final pdf = await _generatePdf();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Resume Preview')),
          body: PdfPreview(
            build: (format) => pdf.save(),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPdf() async {
    final pdf = await _generatePdf();
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final output = await getExternalStorageDirectory();
      final file = File('${output?.path}/advanced_resume.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to save PDF')),
      );
    }
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    final headingFont = await PdfGoogleFonts.nunitoBold();
    final bodyFont = await PdfGoogleFonts.nunitoRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(_nameController.text, style: pw.TextStyle(font: headingFont, fontSize: 28)),
                      pw.SizedBox(height: 5),
                      pw.Text(_emailController.text, style: pw.TextStyle(font: bodyFont, fontSize: 12)),
                      pw.Text(_phoneController.text, style: pw.TextStyle(font: bodyFont, fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('LinkedIn: ${_linkedinController.text}', style: pw.TextStyle(font: bodyFont, fontSize: 12)),
                      pw.Text('GitHub: ${_githubController.text}', style: pw.TextStyle(font: bodyFont, fontSize: 12)),
                      pw.Text('Portfolio: ${_portfolioController.text}', style: pw.TextStyle(font: bodyFont, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            _buildPdfSection('Professional Summary', _summaryController.text, headingFont, bodyFont),
            _buildPdfSection('Experience', _experienceController.text, headingFont, bodyFont),
            _buildPdfSection('Education', _educationController.text, headingFont, bodyFont),
            _buildPdfSection('Skills', _skillsController.text, headingFont, bodyFont),
            _buildPdfSection('Projects', _projectsController.text, headingFont, bodyFont),
            _buildPdfSection('Awards and Achievements', _awardsController.text, headingFont, bodyFont),
          ];
        },
      ),
    );
    return pdf;
  }

  pw.Widget _buildPdfSection(String title, String content, pw.Font headingFont, pw.Font bodyFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(level: 1, text: title, textStyle: pw.TextStyle(font: headingFont, fontSize: 18)),
        pw.Text(content, style: pw.TextStyle(font: bodyFont, fontSize: 12)),
        pw.SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        maxLines: maxLines,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Resume Maker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_nameController, 'Full Name'),
                _buildTextField(_emailController, 'Email'),
                _buildTextField(_phoneController, 'Phone'),
                _buildTextField(_linkedinController, 'LinkedIn Profile URL'),
                _buildTextField(_githubController, 'GitHub Profile URL'),
                _buildTextField(_portfolioController, 'Portfolio Website URL'),
                const SizedBox(height: 20),
                Text('Professional Summary', style: Theme.of(context).textTheme.titleLarge),
                _buildTextField(_summaryController, 'Summary', maxLines: 5),
                const SizedBox(height: 20),
                Text('Experience', style: Theme.of(context).textTheme.titleLarge),
                _buildTextField(_experienceController, 'Work Experience', maxLines: 10),
                const SizedBox(height: 20),
                Text('Education', style: Theme.of(context).textTheme.titleLarge),
                _buildTextField(_educationController, 'Education', maxLines: 5),
                const SizedBox(height: 20),
                Text('Skills', style: Theme.of(context).textTheme.titleLarge),
                _buildTextField(_skillsController, 'Skills', maxLines: 5),
                const SizedBox(height: 20),
                Text('Projects', style: Theme.of(context).textTheme.titleLarge),
                _buildTextField(_projectsController, 'Projects', maxLines: 10),
                const SizedBox(height: 20),
                Text('Awards and Achievements', style: Theme.of(context).textTheme.titleLarge),
                _buildTextField(_awardsController, 'Awards', maxLines: 5),
                const SizedBox(height: 20),
                Center(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Enhance with AI'),
                        onPressed: _isLoading ? null : _enhanceWithAI,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.preview),
                        label: const Text('Preview Resume'),
                        onPressed: _previewPdf,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Download Resume'),
                        onPressed: _downloadPdf,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SpinKitCubeGrid(
                  color: Colors.white,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Advanced Resume Maker'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const MarkdownBody(
                  data: '''
# Advanced Resume Maker

This app helps you create a professional resume with ease.

## Features:
- Fill in your details
- Enhance content with AI
- Generate a PDF resume

Created by: Your Name
Version: 1.2.0

[Visit our website](https://www.example.com)

**GitHub Repository:** [Advanced Resume Maker](https://github.com/yourusername/advanced-resume-maker)
                  ''',
                  selectable: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('View on GitHub'),
                  onPressed: () => launchUrl(Uri.parse('https://github.com/yourusername/advanced-resume-maker')),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}












