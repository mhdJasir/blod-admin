import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OverlayDropdown<T> extends StatefulWidget {
  final Widget? child;
  final void Function(T, int)? onChange;
  final List<DropdownItem<T>> items;
  final DropdownStyle? dropdownStyle;
  final DropdownButtonStyle? dropdownButtonStyle;
  final Icon? icon;
  final bool hideIcon;
  final double? margin;
  final Alignment? menuAlign;
  final bool leadingIcon;
  final BuildContext? customContext;

  const OverlayDropdown({
    Key? key,
    this.hideIcon = false,
    this.child,
    required this.items,
    this.dropdownStyle,
    this.dropdownButtonStyle,
    this.icon,
    this.leadingIcon = false,
    required this.onChange,
    this.customContext,
    this.margin,
    this.menuAlign,
  }) : super(key: key);

  @override
  OverlayDropdownState<T> createState() => OverlayDropdownState<T>();
}

class OverlayDropdownState<T> extends State<OverlayDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  int _currentIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    focusNode.addListener(() {
      if (_isOpen && focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });
  }

  final focusNode = FocusNode();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var style = widget.dropdownButtonStyle;
    return CompositedTransformTarget(
      link: this._layerLink,
      child: SizedBox(
        width: style?.width,
        height: style?.height,
        child: InkWell(
          onTap: _toggleDropdown,
          child: widget.child ??
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: style?.primaryColor, padding: style?.padding,
                  backgroundColor: style?.backgroundColor,
                  elevation: style?.elevation,
                  // shape: style.shape,
                ),
                onPressed: _toggleDropdown,
                child: Row(
                  mainAxisAlignment:
                      style?.mainAxisAlignment ?? MainAxisAlignment.center,
                  textDirection: widget.leadingIcon
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: (_currentIndex == -1)
                          ? Container()
                          : widget.items[_currentIndex],
                    ),
                    Visibility(
                      visible: !widget.hideIcon,
                      child: RotationTransition(
                        alignment: Alignment.center,
                        turns: _rotateAnimation,
                        child: widget.icon ?? const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox? renderBox =
        (widget.customContext ?? context).findRenderObject() as RenderBox;
    var size = renderBox.size;

    var offset = renderBox.localToGlobal(Offset.zero);
    var topOffset = offset.dy + size.height + 5;
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () => _toggleDropdown(close: true),
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: topOffset,
                width: widget.dropdownStyle?.width ??
                    (size.width - (widget.margin ?? 0)),
                child: CompositedTransformFollower(
                  offset: widget.dropdownStyle?.offset ??
                      Offset(0, size.height + 5),
                  link: this._layerLink,
                  showWhenUnlinked: false,
                  followerAnchor: widget.menuAlign ?? Alignment.topLeft,
                  child: Material(
                    elevation: widget.dropdownStyle?.elevation ?? 5,
                    borderRadius:
                        widget.dropdownStyle?.borderRadius ?? BorderRadius.zero,
                    color: widget.dropdownStyle?.color,
                    child: SizeTransition(
                      axisAlignment: 1,
                      sizeFactor: _expandAnimation,
                      child: ConstrainedBox(
                        constraints: widget.dropdownStyle?.constraints ??
                            BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height -
                                  topOffset -
                                  15,
                            ),
                        child: KeyboardListener(
                          focusNode: focusNode,
                          child: ListView(
                            padding: widget.dropdownStyle?.padding ??
                                EdgeInsets.zero,
                            shrinkWrap: true,
                            children: widget.items.asMap().entries.map((item) {
                              return InkWell(
                                onTap: () {
                                  setState(() => _currentIndex = item.key);
                                  _toggleDropdown(close: true);
                                  if (widget.onChange != null) {
                                    widget.onChange!(
                                        item.value.value, item.key);
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  alignment: Alignment.centerLeft,
                                  child: item.value,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDropdown({bool close = false}) async {
    if (_isOpen || close) {
      await _animationController.reverse();
      this._overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
      setState(() {});
      focusNode.unfocus();
    } else {
      this._overlayEntry = this._createOverlayEntry();
      Overlay.of(context).insert(this._overlayEntry!);
      setState(() => _isOpen = true);
      _animationController.forward();
      focusNode.requestFocus();
    }
  }
}

class DropdownItem<T> extends StatelessWidget {
  final T value;
  final Widget child;

  const DropdownItem({Key? key, required this.value, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class DropdownButtonStyle {
  final MainAxisAlignment? mainAxisAlignment;
  final ShapeBorder? shape;
  final double? elevation;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;
  final double? width;
  final double? height;
  final Color? primaryColor;

  const DropdownButtonStyle({
    this.mainAxisAlignment,
    this.backgroundColor,
    this.primaryColor,
    this.constraints,
    this.height,
    this.width,
    this.elevation,
    this.padding,
    this.shape,
  });
}

class DropdownStyle {
  final BorderRadius? borderRadius;
  final double? elevation;
  final Color? color;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;

  final Offset? offset;
  final double? width;

  const DropdownStyle({
    this.constraints,
    this.offset,
    this.width,
    this.elevation,
    this.color,
    this.padding,
    this.borderRadius,
  });
}
