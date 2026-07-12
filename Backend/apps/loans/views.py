from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.core.pagination import StandardPagination
from apps.core.responses import EnvelopeAPIView, success_response
from apps.loans.permissions import (
    IsChamaChairpersonOrTreasurer,
    IsChamaCommitteeMember,
    IsChamaTreasurer,
)
from apps.loans.serializers import (
    CommitteeVoteCreateSerializer,
    CommitteeVoteSerializer,
    LoanApplicationApproveSerializer,
    LoanApplicationCreateSerializer,
    LoanApplicationRejectSerializer,
    LoanApplicationSerializer,
    LoanApplicationUpdateSerializer,
    LoanProductCreateSerializer,
    LoanProductSerializer,
    LoanProductUpdateSerializer,
    LoanRepaymentCreateSerializer,
    LoanRepaymentSerializer,
)
from apps.loans.services.committee_vote_service import CommitteeVoteService
from apps.loans.services.loan_application_service import LoanApplicationService
from apps.loans.services.loan_product_service import LoanProductService
from apps.loans.services.loan_repayment_service import LoanRepaymentService
from apps.memberships.permissions import IsChamaChairperson, IsChamaMember


@extend_schema_view(
    get=extend_schema(
        tags=["Loan Products"],
        summary="List loan products for a Chama",
        responses={200: LoanProductSerializer(many=True)},
    ),
    post=extend_schema(
        tags=["Loan Products"],
        summary="Create a loan product",
        request=LoanProductCreateSerializer,
        responses={201: LoanProductSerializer},
    ),
)
class LoanProductListCreateView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        if self.request.method == "POST":
            return [IsAuthenticated(), IsChamaChairpersonOrTreasurer()]
        return super().get_permissions()

    def get(self, request, chama_id):
        chama = LoanProductService.get_chama(chama_id)
        search = request.query_params.get("search")
        is_active = request.query_params.get("is_active")
        ordering = request.query_params.get("ordering", "name")
        products = LoanProductService.list_products(
            chama=chama,
            search=search,
            is_active=is_active,
            ordering=ordering,
        )
        serializer = LoanProductSerializer(products, many=True)
        return success_response(
            data=serializer.data,
            message="Loan products retrieved successfully.",
        )

    def post(self, request, chama_id):
        chama = LoanProductService.get_chama(chama_id)
        serializer = LoanProductCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        product = LoanProductService.create_product(chama, serializer.validated_data)
        return success_response(
            data=LoanProductSerializer(product).data,
            message="Loan product created successfully.",
            status_code=status.HTTP_201_CREATED,
        )


@extend_schema_view(
    get=extend_schema(
        tags=["Loan Products"],
        summary="Retrieve loan product details",
        responses={200: LoanProductSerializer},
    ),
    patch=extend_schema(
        tags=["Loan Products"],
        summary="Update a loan product",
        request=LoanProductUpdateSerializer,
        responses={200: LoanProductSerializer},
    ),
    delete=extend_schema(
        tags=["Loan Products"],
        summary="Delete a loan product",
        responses={200: None},
    ),
)
class LoanProductDetailView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        if self.request.method in ("PATCH", "DELETE"):
            return [IsAuthenticated(), IsChamaChairperson()]
        return super().get_permissions()

    def get(self, request, chama_id, pk):
        chama = LoanProductService.get_chama(chama_id)
        product = LoanProductService.get_product(chama, pk)
        return success_response(
            data=LoanProductSerializer(product).data,
            message="Loan product retrieved successfully.",
        )

    def patch(self, request, chama_id, pk):
        chama = LoanProductService.get_chama(chama_id)
        product = LoanProductService.get_product(chama, pk)
        serializer = LoanProductUpdateSerializer(
            product, data=request.data, partial=True
        )
        serializer.is_valid(raise_exception=True)
        product = LoanProductService.update_product(product, serializer.validated_data)
        return success_response(
            data=LoanProductSerializer(product).data,
            message="Loan product updated successfully.",
        )

    def delete(self, request, chama_id, pk):
        chama = LoanProductService.get_chama(chama_id)
        product = LoanProductService.get_product(chama, pk)
        LoanProductService.delete_product(product)
        return success_response(
            data=None,
            message="Loan product deleted successfully.",
        )


@extend_schema_view(
    get=extend_schema(
        tags=["Loan Applications"],
        summary="List loan applications for a Chama",
        responses={200: LoanApplicationSerializer(many=True)},
    ),
    post=extend_schema(
        tags=["Loan Applications"],
        summary="Submit a loan application",
        request=LoanApplicationCreateSerializer,
        responses={201: LoanApplicationSerializer},
    ),
)
class LoanApplicationListCreateView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        if self.request.method == "POST":
            return [IsAuthenticated(), IsChamaMember()]
        return super().get_permissions()

    def get(self, request, chama_id):
        chama = LoanApplicationService.get_chama(chama_id)
        status_filter = request.query_params.get("status")
        member_id = request.query_params.get("member_id")
        search = request.query_params.get("search")
        ordering = request.query_params.get("ordering", "-created_at")
        applications = LoanApplicationService.list_applications(
            chama=chama,
            user=request.user,
            status=status_filter,
            member_id=member_id,
            search=search,
            ordering=ordering,
        )
        paginator = StandardPagination()
        page = paginator.paginate_queryset(applications, request)
        serializer = LoanApplicationSerializer(page, many=True)
        return success_response(
            data={
                "count": paginator.page.paginator.count,
                "next": paginator.get_next_link(),
                "previous": paginator.get_previous_link(),
                "results": serializer.data,
            },
            message="Loan applications retrieved successfully.",
        )

    def post(self, request, chama_id):
        chama = LoanApplicationService.get_chama(chama_id)
        serializer = LoanApplicationCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        application = LoanApplicationService.apply(
            applicant=request.user,
            chama=chama,
            validated_data=data,
            submit=data.get("submit", False),
        )
        return success_response(
            data=LoanApplicationSerializer(application).data,
            message="Loan application created successfully.",
            status_code=status.HTTP_201_CREATED,
        )


@extend_schema_view(
    get=extend_schema(
        tags=["Loan Applications"],
        summary="Retrieve loan application details",
        responses={200: LoanApplicationSerializer},
    ),
    patch=extend_schema(
        tags=["Loan Applications"],
        summary="Update a draft loan application",
        request=LoanApplicationUpdateSerializer,
        responses={200: LoanApplicationSerializer},
    ),
)
class LoanApplicationDetailView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaMember]

    def get(self, request, chama_id, pk):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, pk, request.user)
        return success_response(
            data=LoanApplicationSerializer(application).data,
            message="Loan application retrieved successfully.",
        )

    def patch(self, request, chama_id, pk):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, pk, request.user)
        serializer = LoanApplicationUpdateSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        application = LoanApplicationService.update_application(
            application, request.user, serializer.validated_data
        )
        return success_response(
            data=LoanApplicationSerializer(application).data,
            message="Loan application updated successfully.",
        )


@extend_schema(
    tags=["Loan Applications"],
    summary="Submit a draft loan application",
    responses={200: LoanApplicationSerializer},
)
class LoanApplicationSubmitView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaMember]

    def post(self, request, chama_id, pk):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, pk, request.user)
        application = LoanApplicationService.submit(application, request.user)
        return success_response(
            data=LoanApplicationSerializer(application).data,
            message="Loan application submitted successfully.",
        )


@extend_schema(
    tags=["Loan Applications"],
    summary="Cancel a loan application",
    responses={200: LoanApplicationSerializer},
)
class LoanApplicationCancelView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaMember]

    def post(self, request, chama_id, pk):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, pk, request.user)
        application = LoanApplicationService.cancel(application, request.user)
        return success_response(
            data=LoanApplicationSerializer(application).data,
            message="Loan application cancelled successfully.",
        )


@extend_schema(
    tags=["Loan Applications"],
    summary="Approve a loan application",
    request=LoanApplicationApproveSerializer,
    responses={200: LoanApplicationSerializer},
)
class LoanApplicationApproveView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaCommitteeMember]

    def post(self, request, chama_id, pk):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, pk, request.user)
        serializer = LoanApplicationApproveSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        application = LoanApplicationService.approve(
            application,
            request.user,
            approved_amount=serializer.validated_data.get("approved_amount"),
            remarks=serializer.validated_data.get("remarks", ""),
        )
        return success_response(
            data=LoanApplicationSerializer(application).data,
            message="Loan application approved successfully.",
        )


@extend_schema(
    tags=["Loan Applications"],
    summary="Reject a loan application",
    request=LoanApplicationRejectSerializer,
    responses={200: LoanApplicationSerializer},
)
class LoanApplicationRejectView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaCommitteeMember]

    def post(self, request, chama_id, pk):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, pk, request.user)
        serializer = LoanApplicationRejectSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        application = LoanApplicationService.reject(
            application,
            request.user,
            remarks=serializer.validated_data.get("remarks", ""),
        )
        return success_response(
            data=LoanApplicationSerializer(application).data,
            message="Loan application rejected successfully.",
        )


@extend_schema(
    tags=["Loan Applications"],
    summary="Disburse an approved loan",
    responses={200: LoanApplicationSerializer},
)
class LoanApplicationDisburseView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaTreasurer]

    def post(self, request, chama_id, pk):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, pk, request.user)
        application = LoanApplicationService.disburse(application, request.user)
        return success_response(
            data=LoanApplicationSerializer(application).data,
            message="Loan disbursed successfully.",
        )


@extend_schema_view(
    get=extend_schema(
        tags=["Committee Voting"],
        summary="List committee votes for a loan application",
        responses={200: CommitteeVoteSerializer(many=True)},
    ),
    post=extend_schema(
        tags=["Committee Voting"],
        summary="Cast a committee vote",
        request=CommitteeVoteCreateSerializer,
        responses={201: CommitteeVoteSerializer},
    ),
)
class CommitteeVoteListCreateView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaCommitteeMember]

    def get(self, request, chama_id, loan_id):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, loan_id, request.user)
        votes = CommitteeVoteService.list_votes(application, request.user)
        serializer = CommitteeVoteSerializer(votes, many=True)
        return success_response(
            data=serializer.data,
            message="Committee votes retrieved successfully.",
        )

    def post(self, request, chama_id, loan_id):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, loan_id, request.user)
        serializer = CommitteeVoteCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        vote = CommitteeVoteService.cast_vote(
            application, request.user, serializer.validated_data
        )
        application.refresh_from_db()
        return success_response(
            data={
                "vote": CommitteeVoteSerializer(vote).data,
                "application": LoanApplicationSerializer(application).data,
            },
            message="Vote recorded successfully.",
            status_code=status.HTTP_201_CREATED,
        )


@extend_schema_view(
    get=extend_schema(
        tags=["Loan Repayments"],
        summary="List repayments for a loan application",
        responses={200: LoanRepaymentSerializer(many=True)},
    ),
    post=extend_schema(
        tags=["Loan Repayments"],
        summary="Record a loan repayment",
        request=LoanRepaymentCreateSerializer,
        responses={201: LoanRepaymentSerializer},
    ),
)
class LoanRepaymentListCreateView(EnvelopeAPIView):
    def get_permissions(self):
        if self.request.method == "GET":
            return [IsAuthenticated(), IsChamaMember()]
        if self.request.method == "POST":
            return [IsAuthenticated(), IsChamaTreasurer()]
        return super().get_permissions()

    def get(self, request, chama_id, loan_id):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, loan_id, request.user)
        repayments = LoanRepaymentService.list_repayments(application)
        paginator = StandardPagination()
        page = paginator.paginate_queryset(repayments, request)
        serializer = LoanRepaymentSerializer(page, many=True)
        return success_response(
            data={
                "count": paginator.page.paginator.count,
                "next": paginator.get_next_link(),
                "previous": paginator.get_previous_link(),
                "results": serializer.data,
            },
            message="Loan repayments retrieved successfully.",
        )

    def post(self, request, chama_id, loan_id):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, loan_id, request.user)
        serializer = LoanRepaymentCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        repayment = LoanRepaymentService.record_repayment(
            application, request.user, serializer.validated_data
        )
        application.refresh_from_db()
        return success_response(
            data={
                "repayment": LoanRepaymentSerializer(repayment).data,
                "application": LoanApplicationSerializer(application).data,
            },
            message="Loan repayment recorded successfully.",
            status_code=status.HTTP_201_CREATED,
        )


@extend_schema(
    tags=["Loan Repayments"],
    summary="Retrieve loan repayment details",
    responses={200: LoanRepaymentSerializer},
)
class LoanRepaymentDetailView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaMember]

    def get(self, request, chama_id, loan_id, pk):
        chama = LoanApplicationService.get_chama(chama_id)
        application = LoanApplicationService.get_application(chama, loan_id, request.user)
        repayment = LoanRepaymentService.get_repayment(application, pk)
        return success_response(
            data=LoanRepaymentSerializer(repayment).data,
            message="Loan repayment retrieved successfully.",
        )
