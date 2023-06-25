import "@typespec/rest";
import "@typespec/versioning";
import "@azure-tools/typespec-azure-core";

using TypeSpec.Http;
using TypeSpec.Rest;
using TypeSpec.Versioning;
using Azure.Core;
using Azure.Core.Traits;

@useAuth(
  ApiKeyAuth<ApiKeyLocation.header, "api-key"> | OAuth2Auth<[
    {
      type: OAuth2FlowType.implicit,
      authorizationUrl: "https://login.contoso.com/common/oauth2/v2.0/authorize",
      scopes: ["https://widget.contoso.com/.default"],
    }
  ]>
)
@service({
  title: "Contoso Widget Manager",
})
@server(
  "{endpoint}/widget",
  "Contoso Widget APIs",
  {
    @doc("""
Supported Widget Services endpoints (protocol and hostname, for example:
https://westus.api.widget.contoso.com).
""")
    endpoint: string,
  }
)
@versioned(Contoso.WidgetManager.Versions)
namespace Contoso.WidgetManager;

@doc("The Contoso Widget Manager service version.")
enum Versions {
  @doc("Version 2022-08-31")
  @useDependency(Azure.Core.Versions.v1_0_Preview_2)
  `2022-08-30`,
}

// Models ////////////////////

@doc("A widget.")
@resource("widgets")
model Widget {
  @key("widgetName")
  @doc("The widget name.")
  @visibility("read")
  name: string;

  @doc("The widget color.")
  color: string;
}

// Operations ////////////////////

alias ServiceTraits = NoRepeatableRequests &
  NoConditionalRequests &
  NoClientRequestId;

alias Operations = Azure.Core.ResourceOperations<ServiceTraits>;

interface Widgets {
  // Widget Operations
  #suppress "@azure-tools/typespec-azure-core/use-standard-operations"
  @doc("Create or update a Widget")
  @autoRoute
  @patch
  createOrUpdateWidget(
      ...Azure.Core.Foundations.ApiVersionParameter;

      ...Azure.Core.Foundations.ItemKeysOf<Widget>;

      @doc("This request has a JSON Merge Patch body.")
      @TypeSpec.Http.header("Content-Type")
      contentType: "application/merge-patch+json";

      @doc("The resource instance.")
      @body
      resource: Widget;
  ) : TypeSpec.Http.Response<200> & Widget | TypeSpec.Http.Response<201> & Widget | Azure.Core.Foundations.ErrorResponse;
}
