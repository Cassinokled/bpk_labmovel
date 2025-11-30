import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/emprestimo_model.dart';
import '../../models/bloco_model.dart';
import '../../utils/brasilia_time.dart';

/// geracao de relatorios em formato pdf
/// utiliza biblioteca de pdf e printing para criar os documentos em pdf
/// pega informacoes do relatorio_data_service

class RelatorioPdfService {
  Future<void> gerarRelatorio({
    required Bloco? bloco,
    required int emprestimosRealizados,
    required int emprestimosDevolvidos,
    required int emprestimosAtrasadosDevolvidos,
    required int emprestimosAtrasados,
    required List<EmprestimoModel> emprestimosRealizadosLista,
    required List<EmprestimoModel> emprestimosDevolvidosLista,
    required List<EmprestimoModel> emprestimosAtrasadosDevolvidosLista,
    required List<EmprestimoModel> emprestimosAtrasadosLista,
    required Map<String, String> userNames,
    required Map<String, String> equipamentosFormatted,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => _buildPdfContent(
          bloco: bloco,
          emprestimosRealizados: emprestimosRealizados,
          emprestimosDevolvidos: emprestimosDevolvidos,
          emprestimosAtrasadosDevolvidos: emprestimosAtrasadosDevolvidos,
          emprestimosAtrasados: emprestimosAtrasados,
          emprestimosRealizadosLista: emprestimosRealizadosLista,
          emprestimosDevolvidosLista: emprestimosDevolvidosLista,
          emprestimosAtrasadosDevolvidosLista: emprestimosAtrasadosDevolvidosLista,
          emprestimosAtrasadosLista: emprestimosAtrasadosLista,
          userNames: userNames,
          equipamentosFormatted: equipamentosFormatted,
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  List<pw.Widget> _buildPdfContent({
    required Bloco? bloco,
    required int emprestimosRealizados,
    required int emprestimosDevolvidos,
    required int emprestimosAtrasadosDevolvidos,
    required int emprestimosAtrasados,
    required List<EmprestimoModel> emprestimosRealizadosLista,
    required List<EmprestimoModel> emprestimosDevolvidosLista,
    required List<EmprestimoModel> emprestimosAtrasadosDevolvidosLista,
    required List<EmprestimoModel> emprestimosAtrasadosLista,
    required Map<String, String> userNames,
    required Map<String, String> equipamentosFormatted,
  }) {
    List<pw.Widget> widgets = [];

    // cabecalho
    widgets.add(_buildHeader(bloco));

    // resumo
    widgets.add(_buildResumo(
      emprestimosRealizados: emprestimosRealizados,
      emprestimosDevolvidos: emprestimosDevolvidos,
      emprestimosAtrasadosDevolvidos: emprestimosAtrasadosDevolvidos,
      emprestimosAtrasados: emprestimosAtrasados,
    ));

    // secoes mais detalhadas
    widgets.addAll(_buildEmprestimosAtrasadosDevolvidosHoje(
      emprestimosAtrasadosDevolvidosLista,
      userNames,
      equipamentosFormatted,
    ));

    widgets.addAll(_buildEmprestimosAtrasadosAtivos(
      emprestimosAtrasadosLista,
      userNames,
      equipamentosFormatted,
    ));

    widgets.addAll(_buildEmprestimosDevolvidosHoje(
      emprestimosDevolvidosLista,
      userNames,
      equipamentosFormatted,
    ));

    return widgets;
  }

  pw.Widget _buildHeader(Bloco? bloco) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Relatório Diário',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        if (bloco != null)
          pw.Text(
            'Bloco: ${bloco.nome}',
            style: pw.TextStyle(fontSize: 18),
          ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Data: ${BrasiliaTime.now().toString().split(' ')[0]}',
          style: pw.TextStyle(fontSize: 16),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildResumo({
    required int emprestimosRealizados,
    required int emprestimosDevolvidos,
    required int emprestimosAtrasadosDevolvidos,
    required int emprestimosAtrasados,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resumo',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Empréstimos realizados hoje: $emprestimosRealizados'),
        pw.Text('Empréstimos devolvidos hoje: $emprestimosDevolvidos'),
        pw.Text('Empréstimos atrasados devolvidos hoje: $emprestimosAtrasadosDevolvidos'),
        pw.Text('Empréstimos atrasados: $emprestimosAtrasados'),
        pw.SizedBox(height: 20),
      ],
    );
  }

  List<pw.Widget> _buildEmprestimosAtrasadosDevolvidosHoje(
    List<EmprestimoModel> lista,
    Map<String, String> userNames,
    Map<String, String> equipamentosFormatted,
  ) {
    if (lista.isEmpty) return [];

    return [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Empréstimos Atrasados Devolvidos Hoje',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          ...lista.map((emprestimo) => _buildEmprestimoItem(
            emprestimo,
            userNames,
            equipamentosFormatted,
            includeReturnDate: true,
          )),
          pw.SizedBox(height: 20),
        ],
      ),
    ];
  }

  List<pw.Widget> _buildEmprestimosAtrasadosAtivos(
    List<EmprestimoModel> lista,
    Map<String, String> userNames,
    Map<String, String> equipamentosFormatted,
  ) {
    if (lista.isEmpty) return [];

    return [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Empréstimos Atrasados Ativos',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          ...lista.map((emprestimo) => _buildEmprestimoItem(
            emprestimo,
            userNames,
            equipamentosFormatted,
            includeDeadline: true,
          )),
          pw.SizedBox(height: 20),
        ],
      ),
    ];
  }

  List<pw.Widget> _buildEmprestimosDevolvidosHoje(
    List<EmprestimoModel> lista,
    Map<String, String> userNames,
    Map<String, String> equipamentosFormatted,
  ) {
    if (lista.isEmpty) return [];

    return [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Empréstimos Realizados e Devolvidos hoje',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          ...lista.map((emprestimo) => _buildEmprestimoItem(
            emprestimo,
            userNames,
            equipamentosFormatted,
            includeReturnDate: true,
            includeUserName: false,
          )),
        ],
      ),
    ];
  }

  pw.Widget _buildEmprestimoItem(
    EmprestimoModel emprestimo,
    Map<String, String> userNames,
    Map<String, String> equipamentosFormatted, {
    bool includeReturnDate = false,
    bool includeDeadline = false,
    bool includeUserName = true,
  }) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 10),
      padding: pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('ID: ${emprestimo.id}'),
          if (includeUserName)
            pw.Text('Usuário: ${userNames[emprestimo.userId] ?? emprestimo.userId}'),
          pw.Text('Data do empréstimo: ${emprestimo.criadoEm.toString().split(' ')[0]}'),
          if (includeReturnDate)
            pw.Text('Data da devolução: ${emprestimo.devolvidoEm?.toString().split(' ')[0] ?? 'N/A'}'),
          if (includeDeadline)
            pw.Text('Prazo limite: ${emprestimo.prazoLimiteDevolucao.toString().split(' ')[0]}'),
          pw.Text('Equipamentos: ${emprestimo.codigosEquipamentos.map((codigo) => equipamentosFormatted[codigo] ?? codigo).join(', ')}'),
        ],
      ),
    );
  }
}