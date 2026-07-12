class DomainError(Exception):
    """Raised when a business rule is violated."""

    def __init__(self, message, data=None):
        self.message = message
        self.data = data
        super().__init__(message)
