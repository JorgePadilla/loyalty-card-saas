class Api::V1::Staff::CheckInsController < Api::V1::BaseController
  before_action :require_staff!

  def create
    qr_code = QrCodeService.verify_payload(params[:qr_payload])
    qr_code ||= params[:qr_code] # Allow direct QR code for development

    result = CheckInService.new(
      tenant: ActsAsTenant.current_tenant,
      qr_code: qr_code,
      staff: current_api_user,
      service_name: params[:service_name],
      amount_cents: params[:amount_cents].to_i
    ).call

    if result.success?
      render json: {
        visit: VisitBlueprint.render_as_hash(result.visit),
        points_earned: result.points_earned
      }, status: :created
    else
      render_error(result.error)
    end
  end

  private

  def require_staff!
    render_error("Staff access required", status: :forbidden) unless current_api_user.staff_or_above?
  end
end
