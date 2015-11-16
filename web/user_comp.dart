library github_hook.web.user_comp;

import 'dart:async';

import "package:angular2/angular2.dart" hide Response;
import 'package:github_email_notify/browser.dart';
import 'package:firebase/firebase.dart';

@Component(selector: "user-comp", inputs: const ["user", 'selectionItems'])
@View(templateUrl: 'user_comp.html', directives: const [NgIf, NgFor])
class UserComponent implements OnInit {
  UserObject user;

  _FirebaseThing selectionItems;

  onInit() async {
    assert(selectionItems == null);

    var firebase = new Firebase(user.firebaseBase);
    await firebase.authWithCustomToken(user.firebaseSecurityToken);

    selectionItems = new _FirebaseThing(
        firebase, user.availableLabelsFirebasePath, user.myLabelsFirebasePath);
  }

  void toggle(_FirebaseItem item) => selectionItems.toggle(item);
}

class _FirebaseThing {
  final Firebase _items;
  final Firebase _picked;

  Map<String, bool> _itemsCache;
  Map<String, dynamic> _pickedCache;

  final List<_FirebaseItem> items = new List<_FirebaseItem>();

  _FirebaseThing._(this._items, this._picked) {
    _items.onValue.listen((Event e) {
      _itemsCache = e.snapshot.val();
      if (_itemsCache == null) {
        _itemsCache = <String, bool>{};
      }
      _updateMap();
    });

    _picked.onValue.listen((Event e) {
      _pickedCache = e.snapshot.val();
      if (_pickedCache == null) {
        _pickedCache = <String, dynamic>{};
      }
      _updateMap();
    });
  }

  factory _FirebaseThing(Firebase root, String itemsPath, String pickedPath) {
    var items = root.child(itemsPath);
    var picked = root.child(pickedPath);

    return new _FirebaseThing._(items, picked);
  }

  toggle(_FirebaseItem item) async {
    if (!items.contains(item)) {
      // throw? Shouldn't happen
      print("huh?");
      return;
    }

    await new Future.delayed(const Duration(milliseconds: 0));

    var newValue = !_isPicked(item.name);

    if (newValue == true) {
      await _picked.child(item.name).set(true);
    } else {
      await _picked.child(item.name).remove();
    }
  }

  bool _isPicked(String name) {
    if (_pickedCache == null) return null;

    return _pickedCache[name] == true;
  }

  _updateMap() {
    var itemsToAdd = _itemsCache.keys.toList();

    while (itemsToAdd.isNotEmpty) {
      var toAdd = itemsToAdd.removeLast();
      if (!items.any((_FirebaseItem i) => i.name == toAdd)) {
        // TODO: add this in order so it's sorted
        items.add(new _FirebaseItem(toAdd, this));
      }
    }

    var itemsToRemove = items.where((_FirebaseItem item) {
      return !_itemsCache.containsKey(item.name);
    }).toList();

    if (itemsToRemove.isNotEmpty) {
      items.removeWhere(itemsToRemove.contains);
    }

    // Now sort!
    items.sort();
  }
}

class _FirebaseItem implements Comparable<_FirebaseItem> {
  final String name;
  final _FirebaseThing parent;

  bool get selected => parent._isPicked(name);

  _FirebaseItem(this.name, this.parent);

  int compareTo(_FirebaseItem other) => _smartCompare(this.name, other.name);
}

int _smartCompare(String a, String b) {
  var value = a.toLowerCase().compareTo(b.toLowerCase());

  if (value == 0) {
    value = a.compareTo(b);
  }

  return value;
}
