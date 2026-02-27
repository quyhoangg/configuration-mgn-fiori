@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Change Request Header Projection'
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName: 'Change Request',
  typeNamePlural: 'Change Requests',
  title: { type: #STANDARD, value: 'ReqTitle' },
  description: { type: #STANDARD, value: 'Status' }
}

define root view entity ZC_CONF_REQ_H
  as projection on ZIR_CONF_REQ_H
{
      @UI.facet: [
        { id: 'GeneralInfo',
          purpose: #STANDARD,
          type: #IDENTIFICATION_REFERENCE,
          label: 'Request Information',
          position: 10 },
        { id: 'Items',
          purpose: #STANDARD,
          type: #LINEITEM_REFERENCE,
          label: 'Request Items',
          position: 20,
          targetElement: '_Items' }
      ]

      @UI: { lineItem:       [{ position: 10, importance: #HIGH }],
             identification: [{ position: 10 }] }
  key ReqId,

      @UI: { lineItem:       [{ position: 20 }],
             identification: [{ position: 20 }],
             selectionField: [{ position: 10 }] }
      EnvId,

      @UI: { lineItem:       [{ position: 30, importance: #HIGH }],
             identification: [{ position: 30 }],
             selectionField: [{ position: 20 }] }
      ModuleId,

      @UI: { lineItem:       [{ position: 40, importance: #HIGH }],
             identification: [{ position: 40 }] }
      ReqTitle,

      @UI: { identification: [{ position: 50 }] }
      Description,

      @UI: { lineItem:       [{ position: 50, importance: #HIGH }],
             identification: [{ position: 60 }],
             selectionField: [{ position: 30 }] }
      Status,

      @UI: { identification: [{ position: 70 }] }
      Reason,

      @UI: { lineItem:       [{ position: 60 }],
             identification: [{ position: 80 }] }
      CreatedBy,

      @UI: { lineItem:       [{ position: 70 }],
             identification: [{ position: 90 }] }
      CreatedAt,

      ChangedBy,
      ChangedAt,

      @UI: { identification: [{ position: 100 }] }
      ApprovedBy,

      @UI: { identification: [{ position: 110 }] }
      ApprovedAt,

      @UI: { identification: [{ position: 120 }] }
      RejectedBy,

      @UI: { identification: [{ position: 130 }] }
      RejectedAt,

      /* Associations */
      _Items : redirected to composition child ZC_CONF_REQ_I,
      _Env
}
