import 'dart:async';
import 'dart:convert';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:rxdart/rxdart.dart';

class EsOrdersBloc {
  EsOrdersState _esOrdersState;
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  String searchText = '';

  StreamSubscription<EsBusinessesState> _subscription;

  BehaviorSubject<EsOrdersState> _subjectEsOrdersState;

  EsOrdersBloc(this.httpService, this.esBusinessesBloc) {
    _esOrdersState = new EsOrdersState();
    this._subjectEsOrdersState =
        new BehaviorSubject<EsOrdersState>.seeded(_esOrdersState);

    _subscription =
        this.esBusinessesBloc.esBusinessesStateObservable.listen((event) {
      resetDataState();
    });
  }

  Observable<EsOrdersState> get esOrdersStateObservable =>
      _subjectEsOrdersState.stream;

  resetDataState() {
    _esOrdersState = new EsOrdersState();
    this._updateState();
  }

  getOrders(String orderStatus) {
    getDeliveryAgents();
    this._esOrdersState.ordersListStatus[orderStatus].fetchingStatus =
        DataState.LOADING;
    this._updateState();

    String apiPath = EsApiPaths.getOrders(
      this.esBusinessesBloc.getSelectedBusinessId(),
      orderStatus: orderStatus == EsOrderStatus.ALL_ORDERS ? null : orderStatus,
    );
    httpService.esGet(apiPath).then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esOrdersState.ordersListStatus[orderStatus].fetchingStatus =
            DataState.SUCCESS;
        this._esOrdersState.ordersListStatus[orderStatus].ordersList =
            EsGetOrdersResponse.fromJson(json.decode(httpResponse.body));
      } else {
        this._esOrdersState.ordersListStatus[orderStatus].fetchingStatus =
            DataState.FAILED;
      }
      this._updateState();
    }).catchError(
      (onError) {
        this._esOrdersState.ordersListStatus[orderStatus].fetchingStatus =
            DataState.FAILED;
        this._updateState();
      },
    );
  }

  loadMore(String orderStatus) {
    if (this._esOrdersState.ordersListStatus[orderStatus].ordersList == null ||
        this._esOrdersState.loadMoreStatus == DataState.LOADING) {
      return;
    }
    if (this._esOrdersState.ordersListStatus[orderStatus].ordersList.next ==
        null) {
      return;
    }
    this._esOrdersState.loadMoreStatus = DataState.LOADING;
    this._updateState();
    httpService
        .esGetUrl(
            this._esOrdersState.ordersListStatus[orderStatus].ordersList.next)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        List<EsOrder> previousItems =
            _esOrdersState.ordersListStatus[orderStatus].ordersList.results;
        this._esOrdersState.ordersListStatus[orderStatus].ordersList =
            EsGetOrdersResponse.fromJson(
          json.decode(httpResponse.body),
        );
        this._esOrdersState.ordersListStatus[orderStatus].ordersList.results = [
          ...previousItems,
          ...this
              ._esOrdersState
              .ordersListStatus[orderStatus]
              .ordersList
              .results
        ];
        this._esOrdersState.loadMoreStatus = DataState.SUCCESS;
      } else {
        this._esOrdersState.loadMoreStatus = DataState.FAILED;
      }
      this._updateState();
    }).catchError((err) {
      this._esOrdersState.loadMoreStatus = DataState.FAILED;
      this._updateState();
    });
  }

  getOrderDetails(String orderId) async {
    if (this._esOrdersState.orderDetails.containsKey(orderId)) {
      this._esOrdersState.orderDetailsFetchingStatus[orderId] =
          DataState.SUCCESS;
      this._updateState();
      return;
    }
    this._esOrdersState.orderDetailsFetchingStatus[orderId] = DataState.LOADING;
    this._updateState();
    this
        .httpService
        .esGet(EsApiPaths.getOrderDetail(orderId))
        .then((httpResponse) async {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.orderDetailsFetchingStatus[orderId] =
            DataState.SUCCESS;
        this._esOrdersState.orderDetails.putIfAbsent(
              orderId,
              () => EsOrderDetailsResponse.fromJson(
                json.decode(httpResponse.body),
              ),
            );
      } else {
        this._esOrdersState.orderDetailsFetchingStatus[orderId] =
            DataState.FAILED;
      }
      this._updateState();
    }).catchError((onError) {
      this._esOrdersState.orderDetailsFetchingStatus[orderId] =
          DataState.FAILED;
      this._updateState();
    });
  }

  acceptOrder(String orderId, Function onSuccess, Function(String) onFail) {
    this._esOrdersState.submittingStatus = DataState.LOADING;
    this._updateState();
    this
        .httpService
        .esPost(EsApiPaths.postAcceptOrder(orderId), '')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.submittingStatus = DataState.SUCCESS;
        var createdBusinessInfo =
            EsOrder.fromJson(json.decode(httpResponse.body));
        if (onSuccess != null) {
          onSuccess(createdBusinessInfo);
        }
      } else {
        onFail('error :- ${httpResponse.statusCode}');
        this._esOrdersState.submittingStatus = DataState.FAILED;
      }
      this._updateState();
    }).catchError((onError) {
      onFail(onError?.toString());
      this._esOrdersState.submittingStatus = DataState.FAILED;
      this._updateState();
    });
  }

  cancelOrder(
    String orderId,
    String cancellationReason,
    Function onSuccess,
    Function(String) onFail,
  ) {
    this._esOrdersState.submittingStatus = DataState.LOADING;
    this._updateState();
    var payload = new EsCancelOrderPayload(
      cancellationNote: cancellationReason,
    );
    var payloadString = json.encode(payload.toJson());
    this
        .httpService
        .esPost(EsApiPaths.postCancelOrder(orderId), payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.submittingStatus = DataState.SUCCESS;
        var createdBusinessInfo =
            EsOrder.fromJson(json.decode(httpResponse.body));
        if (onSuccess != null) {
          onSuccess(createdBusinessInfo);
        }
      } else {
        onFail('error :- ${httpResponse.statusCode}');
        this._esOrdersState.submittingStatus = DataState.FAILED;
      }
      this._updateState();
    }).catchError((onError) {
      onFail(onError?.toString());
      this._esOrdersState.submittingStatus = DataState.FAILED;
      this._updateState();
    });
  }

  updateOrderPaymentStatus(
    String orderId,
    String newStatus,
    Function onSuccess,
    Function(String) onFail,
  ) {
    this._esOrdersState.submittingStatus = DataState.LOADING;
    this._updateState();

    var apiCall = (newStatus == EsOrderPaymentStatus.APPROVED)
        ? this.httpService.esPost(EsApiPaths.orderPaymentUpdate(orderId), '')
        : this.httpService.esDel(EsApiPaths.orderPaymentUpdate(orderId));

    apiCall.then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.submittingStatus = DataState.SUCCESS;
        var createdBusinessInfo =
            EsOrder.fromJson(json.decode(httpResponse.body));
        if (onSuccess != null) {
          onSuccess(createdBusinessInfo);
        }
      } else {
        onFail('error :- ${httpResponse.statusCode}');
        this._esOrdersState.submittingStatus = DataState.FAILED;
      }
      this._updateState();
    }).catchError((onError) {
      onFail(onError?.toString());
      this._esOrdersState.submittingStatus = DataState.FAILED;
      this._updateState();
    });
  }

  assignOrder(
    String orderId,
    Function onSuccess,
    Function(String) onFail,
  ) {
    this._esOrdersState.submittingStatus = DataState.LOADING;
    this._updateState();
    var payload = new EsRequestDeliveryPayload(
        deliveryagentIds: this._esOrdersState.selectedDeliveryAgentIds);
    var payloadString = json.encode(payload.toJson());
    this
        .httpService
        .esPost(
            EsApiPaths.postOrderRequestDeliveryAgent(orderId), payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.submittingStatus = DataState.SUCCESS;
        var createdBusinessInfo =
            EsOrder.fromJson(json.decode(httpResponse.body));
        if (onSuccess != null) {
          onSuccess(createdBusinessInfo);
        }
      } else {
        onFail('error :- ${httpResponse.statusCode}');
        this._esOrdersState.submittingStatus = DataState.FAILED;
      }
      this._updateState();
    }).catchError((onError) {
      onFail(onError?.toString());
      this._esOrdersState.submittingStatus = DataState.FAILED;
      this._updateState();
    });
  }

  markReady(
    String orderId,
    Function onSuccess,
    Function(String) onFail,
  ) {
    this._esOrdersState.submittingStatus = DataState.LOADING;
    this._updateState();
    this
        .httpService
        .esPost(EsApiPaths.postReadyOrder(orderId), '')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.submittingStatus = DataState.SUCCESS;
        var createdBusinessInfo =
            EsOrder.fromJson(json.decode(httpResponse.body));
        if (onSuccess != null) {
          onSuccess(createdBusinessInfo);
        }
      } else {
        onFail('error :- ${httpResponse.statusCode}');
        this._esOrdersState.submittingStatus = DataState.FAILED;
      }
      this._updateState();
    }).catchError((onError) {
      onFail(onError?.toString());
      this._esOrdersState.submittingStatus = DataState.FAILED;
      this._updateState();
    });
  }

  markComplete(
    String orderId,
    Function onSuccess,
    Function(String) onFail,
  ) {
    this._esOrdersState.submittingStatus = DataState.LOADING;
    this._updateState();
    this
        .httpService
        .esPost(EsApiPaths.postCompleteOrder(orderId), '')
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.submittingStatus = DataState.SUCCESS;
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        onFail('error :- ${httpResponse.statusCode}');
        this._esOrdersState.submittingStatus = DataState.FAILED;
      }
      this._updateState();
    }).catchError((onError) {
      onFail(onError?.toString());
      this._esOrdersState.submittingStatus = DataState.FAILED;
      this._updateState();
    });
  }

  getDeliveryAgents() {
    if (this._esOrdersState.agents != null) {
      return;
    }
    this._esOrdersState.agentsFetchingStatus = DataState.LOADING;
    this._esOrdersState.agents = [];
    this._updateState();
    httpService
        .esGet(
      EsApiPaths.getDeliveryAgents(
          this.esBusinessesBloc.getSelectedBusinessId()),
    )
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 ||
          httpResponse.statusCode == 201 ||
          httpResponse.statusCode == 202) {
        this._esOrdersState.agentsFetchingStatus = DataState.SUCCESS;
        this._esOrdersState.agents = new List<EsDeliveryAgent>();
        json.decode(httpResponse.body).forEach(
          (v) {
            this._esOrdersState.agents.add(new EsDeliveryAgent.fromJson(v));
          },
        );
      } else {
        this._esOrdersState.agentsFetchingStatus = DataState.FAILED;
      }
      this._updateState();
    }).catchError((onError) {
      this._esOrdersState.agentsFetchingStatus = DataState.SUCCESS;
      this._updateState();
    });
  }

  selectDeliveryAgent(EsDeliveryAgent agent, bool isSelected) {
    this._esOrdersState.agents = this._esOrdersState.agents.map((ag) {
      if (ag.deliveryagentId == agent.deliveryagentId) {
        ag.selectAgent(isSelected);
      }
      return ag;
    }).toList();
    this._updateState();
  }

  updateOrder(
    String orderId,
    Function onSuccess,
    Function(String) onFail,
    UpdateOrderPayload body,
  ) {
    this._esOrdersState.submittingStatus = DataState.LOADING;
    this._updateState();
    this
        .httpService
        .esPatch(EsApiPaths.postUpdateOrder(orderId), jsonEncode(body.toJson()))
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esOrdersState.submittingStatus = DataState.SUCCESS;
        var createdBusinessInfo =
            EsOrder.fromJson(json.decode(httpResponse.body));
        if (onSuccess != null) {
          onSuccess(createdBusinessInfo);
        }
      } else {
        onFail('error :- ${httpResponse.statusCode}');
        this._esOrdersState.submittingStatus = DataState.FAILED;
      }
      this._updateState();
    }).catchError((onError) {
      onFail(onError?.toString());
      this._esOrdersState.submittingStatus = DataState.FAILED;
      this._updateState();
    });
  }

  _updateState() {
    if (!this._subjectEsOrdersState.isClosed) {
      this._subjectEsOrdersState.sink.add(this._esOrdersState);
    }
  }

  dispose() {
    this._subjectEsOrdersState.close();
    this._subscription.cancel();
  }
}

class EsOrdersState {
  Map<String, OrderListStatus> ordersListStatus;

  Map<String, EsOrderDetailsResponse> orderDetails;
  Map<String, DataState> orderDetailsFetchingStatus;

  List<EsDeliveryAgent> agents;
  DataState agentsFetchingStatus;

  DataState loadMoreStatus;
  DataState submittingStatus;

  String errorMessage;

  List<String> get selectedDeliveryAgentIds =>
      agents.map((e) => e.deliveryagentId).toList();

  EsOrdersState() {
    ordersListStatus = {
      EsOrderStatus.CREATED: OrderListStatus(),
      EsOrderStatus.MERCHANT_ACCEPTED: OrderListStatus(),
      EsOrderStatus.READY_FOR_PICKUP: OrderListStatus(),
      EsOrderStatus.REQUESTING_TO_DA: OrderListStatus(),
      EsOrderStatus.ALL_ORDERS: OrderListStatus(),
    };

    this.orderDetails = {};
    this.orderDetailsFetchingStatus = {};

    this.agentsFetchingStatus = DataState.IDLE;
    this.loadMoreStatus = DataState.IDLE;
    this.submittingStatus = DataState.IDLE;

    this.errorMessage = '';
  }
}

class OrderListStatus {
  EsGetOrdersResponse ordersList;
  DataState fetchingStatus;

  OrderListStatus({
    this.ordersList,
    this.fetchingStatus = DataState.IDLE,
  });
}

enum DataState {
  IDLE,
  LOADING,
  SUCCESS,
  FAILED,
}
