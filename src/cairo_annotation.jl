#InspectDR: Secondary annotation (Cairo layer)
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
const ALIGN_MAP = Dict{Symbol, CAlignment}(
	:tl => ALIGN_TOP | ALIGN_LEFT,
	:tc => ALIGN_TOP | ALIGN_HCENTER,
	:tr => ALIGN_TOP | ALIGN_RIGHT,

	:cl => ALIGN_VCENTER | ALIGN_LEFT,
	:cc => ALIGN_VCENTER | ALIGN_HCENTER,
	:cr => ALIGN_VCENTER | ALIGN_RIGHT,

	:bl => ALIGN_BOTTOM | ALIGN_LEFT,
	:bc => ALIGN_BOTTOM | ALIGN_HCENTER,
	:br => ALIGN_BOTTOM | ALIGN_RIGHT,
)


#==Rendering text annotation
===============================================================================#
function render(canvas::PCanvas2D, a::TextAnnotation, ixf::InputXfrm2D)
	align = get(ALIGN_MAP, a.align, ALIGN_BOTTOM | ALIGN_LEFT)
	angle = deg2rad(a.angle)
	pt = map2dev(a.pos, canvas.xf, ixf, canvas.graphbb)
	render(canvas.ctx, a.text, pt, a.font, angle=angle, align=align)
	return
end


#==Rendering markers
===============================================================================#

function render(canvas::PCanvas2D, mkr::HVMarker, ixf::InputXfrm2D)
	const ctx = canvas.ctx
	const graphbb = canvas.graphbb
	if :none == mkr.line.style
		return
	end

	setlinestyle(ctx, LineStyle(mkr.line))
	pt = read2axis(mkr.pos, ixf)
	pt = map2dev(canvas.xf, pt)

	if mkr.vmarker
		drawline(ctx, Point2D(pt.x, graphbb.ymin), Point2D(pt.x, graphbb.ymax))
	end
	if mkr.hmarker
		drawline(ctx, Point2D(graphbb.xmin, pt.y), Point2D(graphbb.xmax, pt.y))
	end

	return
end


#==Rendering polyline for annotation
===============================================================================#
function render(canvas::PCanvas2D, a::PolylineAnnotation, ixf::InputXfrm2D)
	const ctx = canvas.ctx

	x = a.x; y = a.y
	setlinestyle(ctx, LineStyle(a.line))
	pt = map2dev(canvas.xf, Point2D(x[1], y[1]))
	Cairo.move_to(ctx, pt.x, pt.y)
	for i in 2:length(x)
		pt = map2dev(canvas.xf, Point2D(x[i], y[i]))
		Cairo.line_to(ctx, pt.x, pt.y)
	end
	if a.closepath
		Cairo.close_path(ctx)
		renderfill(ctx, a.fillcolor)
	end
	Cairo.stroke(ctx)

#	function xf(x, y)
#		pt = map2dev(canvas.xf, map2axis(Point2D(x,y), ixf))
#		return (x, y)
#	end
	return
end


#==Generic rendering algorithm for annotations
===============================================================================#
#TODO: warn undefined???
render(canvas::PCanvas2D, a::PlotAnnotation, ixf::InputXfrm2D) = nothing

function render(canvas::PCanvas2D, a::PlotAnnotation, ixf::InputXfrm2D, strip::Int)
	if 0 == a.strip || a.strip == strip
		render(canvas, a, ixf)
	end
	return
end

function render{T<:PlotAnnotation}(canvas::PCanvas2D, alist::Vector{T}, ixf::InputXfrm2D, strip::Int)
	for a in alist
		render(canvas, a, ixf, strip)
	end
	return
end

#Last line
