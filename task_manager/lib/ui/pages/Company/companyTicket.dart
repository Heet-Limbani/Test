import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/API/model/CompanyTicketDataModel.dart';
import 'package:task_manager/API/model/genModel.dart';
import '../DashBoard/sidebarAdmin.dart';
import 'package:task_manager/API/Urls.dart';

class CompanyTicket extends StatefulWidget {
  final String id;
  const CompanyTicket({required this.id, Key? key}) : super(key: key);

  @override
  State<CompanyTicket> createState() => _CompanyTicketState();
}

TextEditingController nameController =
    TextEditingController(); // Define the TextEditingController

String id = "";

class _CompanyTicketState extends State<CompanyTicket> {
  late TableSource _source; // Declare _source here

  String? stringResponse;
  late double deviceWidth;
  late double deviceHeight;
  TextEditingController searchLogController = TextEditingController();
  TextEditingController _searchController = TextEditingController();

  var _sortIndex = 0;
  var _sortAsc = true;
  var _customFooter = false;
  var _rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;

  // ignore: avoid_positional_boolean_parameters
  void setSort(int i, bool asc) => setState(() {
        _sortIndex = i;
        _sortAsc = asc;
      });

  @override
  void initState() {
    super.initState();
    id = widget.id;
    _source = TableSource(context); // Initialize _source here
  }

  void refreshTable() {
    setState(() {
      _source.startIndex = 0;
      _source.setNextView();
    });
  }

  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Menu > Company > View > Company Log",
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        foregroundColor: Colors.grey,
        backgroundColor: Colors.transparent,
      ),
      drawer: SideBarAdmin(),
      extendBody: true,
      body: _buildBody(),
    );
  }

  Stack _buildBody() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: deviceHeight * 0.04,
                ),
                _header(),
                SizedBox(
                  height: deviceHeight * 0.02,
                ),
                _table(),
                SizedBox(
                  height: deviceHeight * 0.1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Table heading
  Row _header() {
    return Row(
      children: [
        Text(
          "Ticket Details",
          style: TextStyle(
            color: Colors.blueGrey[900],
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ],
    );
  }

  Column _table() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: deviceHeight * 0.02,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                  ),
                  onSubmitted: (vlaue) {
                    _source.filterServerSide(_searchController.text);
                  },
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _searchController.text = '';
                });
                _source.filterServerSide(_searchController.text);
                ;
              },
              icon: const Icon(Icons.clear),
            ),
            IconButton(
              onPressed: () => _source.filterServerSide(_searchController.text),
              icon: const Icon(Icons.search),
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
              ),
              onPressed: refreshTable,
            ),
          ],
        ),
        SizedBox(
          height: deviceHeight * 0.03,
        ),
        AdvancedPaginatedDataTable(
          addEmptyRows: false,
          source: _source,
          showHorizontalScrollbarAlways: true,
          sortAscending: _sortAsc,
          sortColumnIndex: _sortIndex,
          showFirstLastButtons: true,
          rowsPerPage: _rowsPerPage,
          availableRowsPerPage: const [10, 20, 50, 100, 200],
          onRowsPerPageChanged: (newRowsPerPage) {
            if (newRowsPerPage != null) {
              setState(() {
                _rowsPerPage = newRowsPerPage;
              });
            }
          },
          columns: [
            DataColumn(
              label: const Text('Sr. No.'),
              numeric: true,
              onSort: setSort,
            ),
            DataColumn(
              label: const Text('Name'),
              onSort: setSort,
            ),
            DataColumn(
              label: const Text('Starting Date'),
              onSort: setSort,
            ),
            DataColumn(
              label: const Text('Description'),
              onSort: setSort,
            ),
            DataColumn(
              label: const Text('Amount'),
              onSort: setSort,
            ),
             DataColumn(
              label: const Text('Status'),
              onSort: setSort,
            ),
          ],
          //Optianl override to support custom data row text / translation
          getFooterRowText:
              (startRow, pageSize, totalFilter, totalRowsWithoutFilter) {
            final localizations = MaterialLocalizations.of(context);
            var amountText = localizations.pageRowsInfoTitle(
              startRow,
              pageSize,
              totalFilter ?? totalRowsWithoutFilter,
              false,
            );

            if (totalFilter != null) {
              //Filtered data source show addtional information
              amountText += ' filtered from ($totalRowsWithoutFilter)';
            }

            return amountText;
          },
          customTableFooter: _customFooter
              ? (source, offset) {
                  const maxPagesToShow = 6;
                  const maxPagesBeforeCurrent = 3;
                  final lastRequestDetails = source.lastDetails!;
                  final rowsForPager = lastRequestDetails.filteredRows ??
                      lastRequestDetails.totalRows;
                  final totalPages = rowsForPager ~/ _rowsPerPage;
                  final currentPage = (offset ~/ _rowsPerPage) + 1;
                  final List<int> pageList = [];
                  if (currentPage > 1) {
                    pageList.addAll(
                      List.generate(currentPage - 1, (index) => index + 1),
                    );
                    //Keep up to 3 pages before current in the list
                    pageList.removeWhere(
                      (element) =>
                          element < currentPage - maxPagesBeforeCurrent,
                    );
                  }
                  pageList.add(currentPage);
                  //Add reminding pages after current to the list
                  pageList.addAll(
                    List.generate(
                      maxPagesToShow - (pageList.length - 1),
                      (index) => (currentPage + 1) + index,
                    ),
                  );
                  pageList.removeWhere((element) => element > totalPages);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: pageList
                        .map(
                          (e) => TextButton(
                            onPressed: e != currentPage
                                ? () {
                                    //Start index is zero based
                                    source.setNextView(
                                      startIndex: (e - 1) * _rowsPerPage,
                                    );
                                  }
                                : null,
                            child: Text(
                              e.toString(),
                            ),
                          ),
                        )
                        .toList(),
                  );
                }
              : null,
        ),
      ],
    );
  }
}

typedef SelectedCallBack = Function(String id, bool newSelectState);

class TableSource extends AdvancedDataTableSource<CompanyTicketDataModel> {
  final BuildContext context; // Add the context parameter

  TableSource(this.context);

  List<String> selectedIds = [];
  String lastSearchTerm = '';

  int startIndex = 0; // Add the startIndex variable

  @override
  DataRow? getRow(int index) {
    final srNo = (startIndex + index + 1).toString();
    final CompanyTicketDataModel dataList = lastDetails!.rows[index];
     String statusText = '';
     if (dataList.status == "0") {
      statusText = "Unassigned";
    } else if (dataList.status == "1") {
      statusText = "Assigned";
    } else if (dataList.status == "2") {
      statusText = "In Progress";
    } else if (dataList.status == "3") {
      statusText = "Query Raised";
    } else if (dataList.status == "4") {
      statusText = "Completed";
    } else if (dataList.status == "5") {
      statusText = "Completed & Reviewed";
    } else if (dataList.status == "6") {
      statusText = "Invoice Raised";
    } else if (dataList.status == "7") {
      statusText = "Paid";
    }

    return DataRow(
      cells: [
        DataCell(Text(srNo)),
        DataCell(Text(dataList.title ?? '')),
        DataCell(Text(dataList.startingDate ?? '')),
        DataCell(Text(dataList.description ?? '')),
        DataCell(Text(dataList.amount ?? '')),
        DataCell(Text(statusText)),
      ],
      // selected: selectedIds.contains(dataList.id),
      // onSelectChanged: (value) {
      //   selectedRow(dataList.id.toString(), value ?? false);
      // },
    );
  }

  @override
  int get selectedRowCount => selectedIds.length;

  // void selectedRow(String id, bool newSelectState) {
  //   if (selectedIds.contains(id)) {
  //     selectedIds.remove(id);
  //   } else {
  //     selectedIds.add(id);
  //   }
  //   notifyListeners();
  // }

  void filterServerSide(String filterQuery) {
    lastSearchTerm = filterQuery.toLowerCase().trim();
    setNextView();
  }

  @override
  Future<RemoteDataSourceDetails<CompanyTicketDataModel>> getNextPage(
    NextPageRequest pageRequest,
  ) async {
    startIndex = pageRequest.offset;
    final queryParameter = <String, dynamic>{
      'id': id,
      'offset': pageRequest.offset.toString(),
      if (lastSearchTerm.isNotEmpty) 'search': lastSearchTerm,
      'limit': pageRequest.pageSize.toString()
    };

    genModel? dataModel = await Urls.postApiCall(
      method: '${Urls.companyTicket}',
      params: queryParameter,
    );

    if (dataModel != null && dataModel.status == true) {
      //int count = dataModel.data.length ?? 0;
      final dynamicData = dataModel.data;
      return RemoteDataSourceDetails(
        dataModel.count ?? 0,
        //count,
        dynamicData
            .map<CompanyTicketDataModel>(
              (item) =>
                  CompanyTicketDataModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        filteredRows: lastSearchTerm.isNotEmpty
            ? dynamicData
                .map<CompanyTicketDataModel>(
                  (item) => CompanyTicketDataModel.fromJson(
                      item as Map<String, dynamic>),
                )
                .length
            : null,
      );
    } else {
      throw Exception('Unable to query remote server');
    }
  }
}
