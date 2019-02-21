$proxy = New-WebServiceProxy -Uri "net.pipe://develops/ActiveBatch/Integration/Host_12920/IDumpServicel" -Namespace JSSWS
$proxy.SoapVersion = [System.Web.Services.Protocols.SoapProtocolVersion]::Soap12
$TagsService = New-Object JSSWS.BasicHttpBinding_ITagService
$TagsService.Credentials = Get-Credential
$TagsService.GetTags()