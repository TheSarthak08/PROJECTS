#include<iostream>
#include<string>
#include<vector>
#include<unordered_map>
using namespace std;

class Item;
class Cart;
class Product{
  int id;
  string name;
  int price;
  public:
  Product(){}
  Product(int uid,string name,int price){
      id = uid;
      this-> name = name;
      this-> price = price;
  }
  string getDisplayName(){
      return  name + ": Rs " + to_string(price) + "\n";
  }
  string getShortName(){
      return name.substr(0,1);
  }
  friend class Item;
  friend class Cart;
};

class Item{
    Product product;
    int quantity;
    public:
    Item(){}
    Item(Product p,int q):product(p),quantity(q){}
    int getItemPrice(){
        return quantity*product.price;
    }
    string getItemInfo(){
        return to_string(quantity) + " x " + product.name + " Rs " + to_string(quantity*product.price) + "\n";
    }
    friend class Cart;
};

class Cart{
    unordered_map <int,Item> items;
    public:
    void addProduct(Product product){
        if(items.count(product.id)==0){
            Item newItem(product,1);
            items[product.id] = newItem;
        }
        else{
            items[product.id].quantity +=1;
        }
        
    }
    int getTotal(){
        int total = 0;
        for(auto itempair : items){
            auto item = itempair.second;
            total += item.getItemPrice();
        }
        return total;
    }
    
    string viewCart(){
        if(items.empty()){
            return "CART IS EMPTY!\n";
        }
        string itemList;
        int cart_total = getTotal();
        for(auto itempair : items){
            auto item = itempair.second;
            itemList.append(item.getItemInfo());
        }
        return itemList + " Total Amount : Rs. " + to_string(cart_total) + "\n";
    }
    bool isEmpty(){
        return items.empty();
    }
};

vector<Product> allProducts = {
    Product(1,"apple",26),
    Product(2,"mango",100),
    Product(3,"guava",20),
    Product(4,"strawberry",60),
    Product(5,"banana",10),
    Product(6,"pineapple",50),
    Product(7,"litchi",40),
};
Product* chooseProduct(){
    string productList;
    for(auto product : allProducts){
        productList.append(product.getDisplayName());
    }
    cout<< productList <<endl;
    cout<< "--------------------------"<<endl;
    string choice;
    cin>>choice;
    for(int i = 0;i<allProducts.size();i++){
        if(allProducts[i].getShortName() == choice){
            return &allProducts[i];
        }
    }
    cout<<"NO SUCH PRODUCT!"<<endl;
    return NULL;
}

bool checkout(Cart& cart){
    if(cart.isEmpty()){
        return false;
    }
    int total = cart.getTotal();
    cout<<"Pay in Cash"<<endl;
    int paid;
    cin>>paid;
    if(paid>=total){
        cout<<"Change : "<<paid-total<<endl;
        cout<<"Thank You for Shopping!"<<endl;
        return true;
    }
    else{
        cout<<"Not Enough Cash"<<endl;
        return false;
    }
}

int main(){
    char action;
    Cart cart;
    while(true){
        cout<< "Select an action - (a)dd item , (v)iew cart , (c)heckout" <<endl;
        cin>>action;
        if(action == 'a'){
            //show all the available item
            Product* product = chooseProduct();
            if(product!= NULL){
                cout<<"ADDED TO CART "<<product->getDisplayName();
                cart.addProduct(*product);
            }
        }
        else if(action == 'v'){
            //show the product in cart
            cout<<"-------------------"<<endl;
            cout<<cart.viewCart();
            cout<<"-------------------"<<endl;
        }
        else if(action == 'c'){
            //checkout
            cart.viewCart();
            if(checkout(cart)){
                break;
            }
        }
        else {
            cout<<"INVALID ACTION!"<<endl;
        }
    }
}
