from logging import Filter, LogRecord


class SpecialFilter(Filter):
    def filter(self, record: LogRecord):
        return record.msg.startswith("Warning!")
