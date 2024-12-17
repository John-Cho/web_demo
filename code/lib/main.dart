import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/services.dart';
import 'package:my_web_app/common/constants.dart';
import 'package:my_web_app/model/order.dart';

void main() {
  runApp(MaterialApp(
    home: ExcelLoader(),
  ));
}

class ExcelLoader extends StatefulWidget {
  @override
  _ExcelLoaderState createState() => _ExcelLoaderState();
}

class _ExcelLoaderState extends State<ExcelLoader> {
  List<Order> orderList = [];

  void _pickAndLoadExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      var fileBytes = result.files.first.bytes;
      var excel = Excel.decodeBytes(fileBytes!);
      _loadExcel(excel);
    } else {
      print("No file selected");
    }
  }

  void _loadExcel(Excel excel) {
    var sheet = excel.sheets.values.first;
    int rowCount = sheet.rows.length - 1;
    int colIdx_name = 0, colIdx_number = 0;

    // 헤더 정보 찾기
    var headerRow = sheet.row(2); // 일반적으로 헤더는 첫 번째 행에 있습니다.
    for (int i = 0; i < sheet.maxCols; i++) {
      var cellValue = (headerRow[i]?.value ?? "").toString();
      if (cellValue == (ORDER_NUMBER)) {
        colIdx_number = i;
      } else if (cellValue == (ORDER_NAME)) {
        colIdx_name = i;
      }
      if (colIdx_number != 0 && colIdx_name != 0) {
        break; // 모든 필요한 인덱스를 찾았으므로 반복 종료
      }
    }

    // 데이터 처리
    // print('max lines : ${sheet.maxRows}');

    for (int i = 1; i < sheet.maxRows; i++) {
      var row = sheet.row(i);
      String name = (row[colIdx_name]?.value ?? "").toString();
      String number = (row[colIdx_number]?.value ?? "").toString();

      if (name.isNotEmpty && number.isNotEmpty && name != ORDER_NAME) {
        orderList.add(Order(name: name, number: number));
      }
    }

    setState(() {});
  }

  void _copyToClipboard(int rowIndex) {
    String rowData = orderList[rowIndex].message;
    Clipboard.setData(ClipboardData(text: rowData)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Copied Row $rowIndex to clipboard'),
        duration: Duration(seconds: 2),
      ));

      setState(() {
        orderList[rowIndex].isCopied = true; // 클립보드 복사 후 배경색 변경을 위해 상태 업데이트
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('멘트 자동 생성기'),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: ElevatedButton(
                    onPressed: _pickAndLoadExcel,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white),
                    child: Text('Load Excel File'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Divider(color: Colors.black, thickness: 1.5,),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: orderList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 8.0),
                        child: GestureDetector(
                          onTap: () => _copyToClipboard(index), // 박스 전체 클릭 시 동작
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: Alignment.center,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border:
                                  Border.all(color: Colors.black54, width: 1.0),
                              color: orderList[index].isCopied
                                  ? Colors.grey[300]
                                  : const Color.fromARGB(255, 2, 96, 139),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              orderList[index].name,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: orderList[index].isCopied
                                    ? Colors.black54
                                    : Colors.white,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
