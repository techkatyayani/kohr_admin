import 'package:Kohr_Admin/constants.dart';
import 'package:flutter/material.dart';

class SelectionButtonData {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  final int? totalNotif;

  SelectionButtonData({
    required this.activeIcon,
    required this.icon,
    required this.label,
    this.totalNotif,
  });
}

class SelectionButton extends StatefulWidget {
  const SelectionButton({
    this.initialSelected = 0,
    required this.data,
    required this.onSelected,
    required int currentIndex,
    super.key,
  });

  final int initialSelected;
  final List<SelectionButtonData> data;
  final Function(int index, SelectionButtonData value) onSelected;

  @override
  State<SelectionButton> createState() => _SelectionButtonState();
}

class _SelectionButtonState extends State<SelectionButton> {
  late int selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.data.asMap().entries.map((e) {
        final index = e.key;
        final data = e.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: _Button(
              selected: selected == index,
              onPressed: () {
                widget.onSelected(index, data);
                setState(() {
                  selected = index;
                });
              },
              data: data,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.selected,
    required this.data,
    required this.onPressed,
  });

  final bool selected;
  final SelectionButtonData data;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: (!selected)
          ? Theme.of(context).cardColor
          : AppColors.primaryBlue.withOpacity(.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
          child: Row(
            children: [
              !selected
                  ? Container()
                  : Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        color: AppColors.primaryBlue,
                      ),
                      width: 5,
                      height: 25,
                    ),
              SizedBox(width: !selected ? 15 : 10),
              _icon((!selected) ? data.icon : data.activeIcon, context),
              const SizedBox(width: 10),
              Expanded(child: _labelText(data.label, context)),
              if (data.totalNotif != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: _notif(data.totalNotif!),
                ),
              // const Spacer(),
              !selected
                  ? Container()
                  : const Icon(Icons.arrow_forward_ios, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(IconData iconData, BuildContext context) {
    return Icon(
      iconData,
      size: 20,
      color: (!selected) ? Colors.black : AppColors.primaryBlue,
    );
  }

  Widget _labelText(String data, BuildContext context) {
    return Text(
      data,
      style: TextStyle(
        color: (!selected) ? Colors.black : AppColors.primaryBlue,
        fontWeight: FontWeight.w600,
        letterSpacing: .8,
        fontSize: 13,
      ),
    );
  }

  Widget _notif(int total) {
    return (total <= 0)
        ? Container()
        : Container(
            width: 30,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              (total >= 100) ? "99+" : "$total",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          );
  }
}
