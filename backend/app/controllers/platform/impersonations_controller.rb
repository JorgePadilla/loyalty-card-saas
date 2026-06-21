# Ends an impersonation started from the platform panel: destroys the tenant
# session and clears the marker, leaving the platform session intact.
class Platform::ImpersonationsController < Platform::BaseController
  def destroy
    Session.find_by(id: cookies.signed[:session_id])&.destroy
    cookies.delete(:session_id)
    cookies.delete(:impersonator_id)
    redirect_to platform_tenants_path, notice: t("platform.tenants.flash.impersonation_ended")
  end
end
