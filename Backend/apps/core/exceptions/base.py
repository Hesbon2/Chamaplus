class DomainError(Exception):
    """Raised when a business rule is violated."""

    def __init__(self, message, data=None, status_code=400):
        self.message = message
        self.data = data
        self.status_code = status_code
        super().__init__(message)
