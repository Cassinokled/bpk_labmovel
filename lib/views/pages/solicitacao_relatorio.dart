import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/app_logo.dart';
import '../../utils/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/solicitacao_relatorio_service.dart';
import '../../models/solicitacao_relatorio_model.dart';
import 'solicitacao_enviada_page.dart';

class SolicitacaoRelatorioPage extends StatefulWidget {
  const SolicitacaoRelatorioPage({super.key});

  @override
  State<SolicitacaoRelatorioPage> createState() => _SolicitacaoRelatorioPageState();
}

class _SolicitacaoRelatorioPageState extends State<SolicitacaoRelatorioPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String? _selectedFileName;

  final AuthService _authService = AuthService();
  final SolicitacaoRelatorioService _solicitacaoService = SolicitacaoRelatorioService();

  Future<void> _selectDate(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const Expanded(
                    child: Center(child: AppLogo()),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Solicitar novo protocolo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 86, 22, 36),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _tituloController,
                        decoration: InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        onTap: () => _selectDate(context, true),
                        decoration: InputDecoration(
                          labelText: 'Data Início',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: _dataInicio == null
                              ? ''
                              : '${_dataInicio!.day.toString().padLeft(2, '0')}/${_dataInicio!.month.toString().padLeft(2, '0')}/${_dataInicio!.year}',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        readOnly: true,
                        onTap: () => _selectDate(context, false),
                        decoration: InputDecoration(
                          labelText: 'Data Fim',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: _dataFim == null
                              ? ''
                              : '${_dataFim!.day.toString().padLeft(2, '0')}/${_dataFim!.month.toString().padLeft(2, '0')}/${_dataFim!.year}',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _motivoController,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          labelText: 'Motivo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles();
                            if (result != null) {
                              setState(() {
                                _selectedFileName = result.files.single.name;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedFileName ?? 'Adicionar Comprovante',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const Icon(Icons.attach_file),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_dataInicio == null || _dataFim == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecione as datas de início e fim')),
                        );
                        return;
                      }

                      final userId = _authService.currentUser?.uid;
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuário não logado')),
                        );
                        return;
                      }

                      final solicitacao = SolicitacaoRelatorioModel(
                        userId: userId,
                        titulo: _tituloController.text,
                        motivo: _motivoController.text,
                        dataInicio: _dataInicio!,
                        dataFim: _dataFim!,
                        comprovanteUrl: _selectedFileName,
                      );

                      try {
                        await _solicitacaoService.criarSolicitacao(solicitacao);

                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const SolicitacaoEnviadaPage(),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao enviar solicitação: $e')),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Confirmar',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _motivoController.dispose();
    super.dispose();
  }
}