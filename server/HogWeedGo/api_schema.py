from rest_framework.schemas.openapi import AutoSchema


class MeSchema(AutoSchema):
    def get_component(self, component):
        pass

    def get_components(self, path, method):
        link = path.split('/')[-1]
        if link == 'prove_email':
            return {'Const': self.get_component('Const:Code was sent')}
        elif link == 'auth':
            return {'Const': self.get_component('Const:Code was sent')}
        elif link == 'log_in':
            return {'Const': self.get_component('Const:Code was sent')}
        elif link == 'setup':
            return {'Results': self.get_component('Results')}
        elif link == 'log_out':
            return {'Const': self.get_component('Const:Code was sent')}
        elif link == 'leave':
            return {'Const': self.get_component('Const:Code was sent')}
        else:
            return {}

    def get_operation(self, path, method):
        return super(MeSchema, self).get_operation(path, method)


class ReportsSchema(AutoSchema):
    def get_components(self, path, method):
        comps = super(ReportsSchema, self).get_components(path, method)
        # print(path, comps)
        return comps

    def get_operation(self, path, method):
        ops = super(ReportsSchema, self).get_operation(path, method)
        # print(path, ops)
        return ops
