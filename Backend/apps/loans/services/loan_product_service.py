from django.db.models import Q

from apps.chamas.services.chama_service import ChamaService
from apps.core.exceptions import DomainError
from apps.loans.models import LoanProduct


class LoanProductService:
    @staticmethod
    def get_chama(chama_id):
        return ChamaService.get_chama(chama_id)

    @staticmethod
    def create_product(chama, validated_data):
        return LoanProduct.objects.create(chama=chama, **validated_data)

    @staticmethod
    def list_products(chama, search=None, is_active=None, ordering="name"):
        queryset = LoanProduct.objects.filter(chama=chama)

        if is_active is not None:
            active_value = str(is_active).lower() in ("true", "1", "yes")
            queryset = queryset.filter(is_active=active_value)

        if search:
            queryset = queryset.filter(
                Q(name__icontains=search) | Q(description__icontains=search)
            )

        allowed_ordering = {"name", "-name", "created_at", "-created_at"}
        if ordering not in allowed_ordering:
            raise DomainError("Invalid ordering field.")
        return queryset.order_by(ordering)

    @staticmethod
    def get_product(chama, product_id):
        try:
            return LoanProduct.objects.get(pk=product_id, chama=chama)
        except LoanProduct.DoesNotExist as exc:
            raise DomainError("Loan product not found.", status_code=404) from exc

    @staticmethod
    def update_product(product, validated_data):
        for field, value in validated_data.items():
            setattr(product, field, value)
        product.save()
        return product

    @staticmethod
    def delete_product(product):
        if product.applications.exists():
            raise DomainError(
                "Cannot delete a loan product with existing applications."
            )
        product.delete()
