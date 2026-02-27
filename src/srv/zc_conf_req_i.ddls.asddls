@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Change Request Item Projection'
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName: 'Request Item',
  typeNamePlural: 'Request Items'
}

define view entity ZC_CONF_REQ_I
  as projection on ZI_CONF_REQ_I
{
      @UI.facet: [
        { id: 'ItemDetail',
          purpose: #STANDARD,
          type: #IDENTIFICATION_REFERENCE,
          label: 'Item Details',
          position: 10 }
      ]

      @UI: { lineItem:       [{ position: 10, importance: #HIGH }],
             identification: [{ position: 10 }] }
  key ReqItemId,

      @UI: { identification: [{ position: 20 }] }
      ReqId,

      @UI: { lineItem:       [{ position: 20, importance: #HIGH }],
             identification: [{ position: 30 }] }
      ConfId,

      @UI: { lineItem:       [{ position: 30, importance: #HIGH }],
             identification: [{ position: 40 }] }
      Action,

      @UI: { lineItem:       [{ position: 40 }],
             identification: [{ position: 50 }] }
      TargetEnvId,

      @UI: { identification: [{ position: 60 }] }
      Notes,

      @UI: { lineItem:       [{ position: 50 }],
             identification: [{ position: 70 }] }
      VersionNo,

      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt,

      /* Associations */
      _Header : redirected to parent ZC_CONF_REQ_H,
      _Catalog,
      _TargetEnv
}
