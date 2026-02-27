@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Configuration Field Definition'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CONF_FIELD_DEF
  as select from zconffielddef
  association to parent ZI_CONF_CATALOG as _Catalog
    on $projection.ConfId = _Catalog.ConfId
{
  key conf_id         as ConfId,
  key field_name      as FieldName,
      field_label     as FieldLabel,
      data_type       as DataType,
      is_required     as IsRequired,
      value_help_type as ValueHelpType,

      /* Associations */
      _Catalog
}
